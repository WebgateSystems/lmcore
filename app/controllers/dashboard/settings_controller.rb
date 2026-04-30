# frozen_string_literal: true

module Dashboard
  class SettingsController < BaseController
    EDITABLE_KEYS = %w[
      site_name site_tagline site_description
      social_facebook social_twitter social_instagram social_youtube youtube_url
      available_locales default_locale
      comments_premoderation_enabled
    ].freeze
    TRANSLATABLE_KEYS = %w[site_name site_tagline site_description].freeze
    BOOLEAN_KEYS = %w[comments_premoderation_enabled].freeze

    def show
      authorize :settings, policy_class: Dashboard::SettingsPolicy
      load_theme_options
      @settings = load_settings
    end

    def update
      authorize :settings, policy_class: Dashboard::SettingsPolicy

      ActiveRecord::Base.transaction do
        apply_theme_selection!
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
      user_settings = SiteSetting.where(user: dashboard_blog_user).index_by(&:key)
      global_settings = SiteSetting.global.index_by(&:key)
      current_locale = I18n.locale.to_s
      active_theme = active_theme_for(dashboard_blog_user)

      EDITABLE_KEYS.each_with_object({}) do |key, hash|
        setting = user_settings[key] || global_settings[key]
        raw_value = setting&.typed_value
        hash[key] = if TRANSLATABLE_KEYS.include?(key)
                      localized_value(raw_value, current_locale)
        elsif key == "available_locales"
                      normalize_available_locales(raw_value)
        elsif BOOLEAN_KEYS.include?(key)
                      normalize_boolean_value(key, raw_value)
        else
                      raw_value.to_s
        end
      end.merge("theme_slug" => active_theme&.slug.to_s)
    end

    def load_theme_options
      @available_themes = Theme.active.available_for(dashboard_blog_user).ordered.select(&:template_available?)
      @active_theme = active_theme_for(dashboard_blog_user)
    end

    def active_theme_for(user)
      theme = user.user_themes.active.includes(:theme).first&.theme
      return theme if theme&.active? && theme.available_for?(user) && theme.template_available?

      Theme.default_theme
    end

    def apply_theme_selection!
      theme_slug = params.dig(:settings, :theme_slug).to_s.strip
      return if theme_slug.blank?

      theme = Theme.active.available_for(dashboard_blog_user).find_by(slug: theme_slug)
      theme = nil unless theme&.template_available?
      raise ArgumentError, t("dashboard.settings.theme_unavailable", default: "This theme is not available for your blog.") unless theme

      user_theme = dashboard_blog_user.user_themes.find_or_initialize_by(theme: theme)
      user_theme.active = true
      user_theme.save!
    end

    def save_site_settings!
      return unless params[:settings].present?

      processed = preprocess_settings_params(settings_params.to_h)

      processed.each do |key, value|
        next unless EDITABLE_KEYS.include?(key)

        setting = SiteSetting.find_or_initialize_by(user: dashboard_blog_user, key: key)
        if TRANSLATABLE_KEYS.include?(key)
          setting.value = { "data" => merge_translation(setting, value) }
          setting.value_type = "json"
        elsif key == "available_locales"
          # Always persist as JSON array -- not as String#to_s'd Array, which
          # is what produced the broken `"[\"en\", \"pl\"]"` blobs we saw in
          # the database before this fix.
          setting.value = { "data" => Array(value) }
          setting.value_type = "json"
        elsif BOOLEAN_KEYS.include?(key)
          setting.value = { "data" => normalize_setting_value(key, value) }
          setting.value_type = "boolean"
        else
          setting.value = { "data" => normalize_setting_value(key, value) }
          setting.value_type = "string"
        end
        setting.category ||= "general"
        setting.save!
      end
    end

    def apply_youtube_integration!
      return if params[:youtube_integration].blank?

      yt = params.require(:youtube_integration).permit(:netscape_cookies, :age_acknowledged, :remove_cookies)

      if truthy?(yt[:remove_cookies])
        dashboard_blog_user.clear_youtube_cookies!
      end

      cookies_text = yt[:netscape_cookies].to_s.strip
      return if cookies_text.blank?

      unless truthy?(yt[:age_acknowledged])
        raise ArgumentError, t("dashboard.settings.youtube_integration.age_required")
      end

      dashboard_blog_user.store_youtube_cookies!(cookies_text)
    end

    def truthy?(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end

    def settings_params
      permitted = EDITABLE_KEYS.map { |k| k == "available_locales" ? { available_locales: [] } : k }
      params.require(:settings).permit(*permitted)
    end

    # Sanitises form payload before persistence:
    #   * `available_locales` becomes a clean Array of canonical locale codes
    #     (only when the form actually submitted that field, so partial PATCHes
    #     don't accidentally wipe the user's locale list).
    #   * `default_locale` is forced to fall inside the effective Array
    #     (otherwise the UI dropdown could end up pointing at a language the
    #     blog no longer publishes in).
    def preprocess_settings_params(attrs)
      result = attrs.dup

      if result.key?("available_locales")
        result["available_locales"] = sanitize_locale_list(result["available_locales"])
      end

      if result.key?("default_locale")
        effective_locales = result["available_locales"] || SiteSetting.blog_available_locale_codes_for(dashboard_blog_user)
        candidate = LocaleTags.canonical_locale_code(result["default_locale"]).to_s
        result["default_locale"] = effective_locales.include?(candidate) ? candidate : (effective_locales.first || "en")
      end

      result
    end

    def sanitize_locale_list(value)
      raw = case value
      when Array  then value
      when String then value.split(",")
      else []
      end

      platform = I18n.available_locales.map(&:to_s)
      raw.map { |code| LocaleTags.canonical_locale_code(code) }
         .compact
         .map(&:to_s)
         .reject(&:blank?)
         .select { |code| platform.include?(code) }
         .uniq
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

    # Returns the available locales as an Array<String> for the form, no
    # matter how the value was historically stored (Array, comma string, or
    # JSON-encoded Array via Array#to_s).
    def normalize_available_locales(value)
      SiteSetting.parse_blog_available_locales(value)
    end

    def normalize_setting_value(key, value)
      if BOOLEAN_KEYS.include?(key)
        ActiveModel::Type::Boolean.new.cast(value)
      else
        value
      end
    end

    def normalize_boolean_value(key, raw_value)
      default = case key
      when "comments_premoderation_enabled" then true
      else false
      end
      raw_value.nil? ? default : ActiveModel::Type::Boolean.new.cast(raw_value)
    end
  end
end
