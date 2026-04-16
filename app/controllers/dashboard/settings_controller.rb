# frozen_string_literal: true

module Dashboard
  class SettingsController < BaseController
    EDITABLE_KEYS = %w[
      site_name site_tagline site_description
      social_facebook social_twitter social_instagram social_youtube youtube_url
      available_locales default_locale
      theme_slug
    ].freeze
    TRANSLATABLE_KEYS = %w[site_name site_tagline site_description].freeze

    def show
      authorize :settings, policy_class: Dashboard::SettingsPolicy
      @settings = load_settings
    end

    def update
      authorize :settings, policy_class: Dashboard::SettingsPolicy

      ActiveRecord::Base.transaction do
        apply_youtube_integration!
        save_site_settings!
      end

      redirect_to dashboard_settings_path, notice: t("dashboard.settings.flash.saved")
    rescue ArgumentError => e
      redirect_to dashboard_settings_path, alert: e.message
    rescue ActiveRecord::RecordInvalid => e
      redirect_to dashboard_settings_path, alert: t("dashboard.settings.flash.failed", error: e.message)
    end

    private

    def load_settings
      user_settings = SiteSetting.where(user: current_user).index_by(&:key)
      global_settings = SiteSetting.global.index_by(&:key)
      current_locale = I18n.locale.to_s

      EDITABLE_KEYS.each_with_object({}) do |key, hash|
        setting = user_settings[key] || global_settings[key]
        raw_value = setting&.typed_value
        hash[key] = if TRANSLATABLE_KEYS.include?(key)
                      localized_value(raw_value, current_locale)
        elsif key == "available_locales"
                      normalize_available_locales(raw_value)
        else
                      raw_value.to_s
        end
      end
    end

    def save_site_settings!
      return unless params[:settings].present?

      settings_params.each do |key, value|
        next unless EDITABLE_KEYS.include?(key)

        setting = SiteSetting.find_or_initialize_by(user: current_user, key: key)
        if TRANSLATABLE_KEYS.include?(key)
          setting.value = { "data" => merge_translation(setting, value) }
          setting.value_type = "json"
        else
          setting.value = { "data" => normalize_setting_value(key, value) }
          setting.value_type ||= "string"
        end
        setting.category ||= "general"
        setting.save!
      end
    end

    def apply_youtube_integration!
      return if params[:youtube_integration].blank?

      yt = params.require(:youtube_integration).permit(:netscape_cookies, :age_acknowledged, :remove_cookies)

      if truthy?(yt[:remove_cookies])
        current_user.clear_youtube_cookies!
      end

      cookies_text = yt[:netscape_cookies].to_s.strip
      return if cookies_text.blank?

      unless truthy?(yt[:age_acknowledged])
        raise ArgumentError, t("dashboard.settings.youtube_integration.age_required")
      end

      current_user.store_youtube_cookies!(cookies_text)
    end

    def truthy?(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end

    def settings_params
      params.require(:settings).permit(*EDITABLE_KEYS)
    end

    def merge_translation(setting, incoming_value)
      locale = I18n.locale.to_s
      existing_value = setting.typed_value
      translations = existing_value.is_a?(Hash) ? existing_value.deep_dup : {}

      if translations.blank? && existing_value.present?
        translations[I18n.default_locale.to_s] = existing_value.to_s
      end

      translations[locale] = incoming_value.to_s
      translations
    end

    def localized_value(value, locale)
      return value.to_s unless value.is_a?(Hash)

      value[locale].presence ||
        value[I18n.default_locale.to_s].presence ||
        value.values.compact.find(&:present?).to_s
    end

    def normalize_available_locales(value)
      return value.join(",") if value.is_a?(Array)

      value.to_s
    end

    def normalize_setting_value(key, value)
      return value.to_s.split(",").map(&:strip).reject(&:blank?) if key == "available_locales"

      value
    end
  end
end
