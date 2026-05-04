# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Set current attributes for auditing and other purposes
  before_action :set_current_attributes
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :normalize_translatable_user_params, if: :devise_controller?

  # Pundit authorization
  after_action :verify_authorized, unless: :skip_pundit_verify?
  after_action :verify_policy_scoped, if: :verify_policy_scope?

  # Handle Pundit errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Stop impersonating - return to original admin user
  def stop_impersonating
    admin_user_id = session[:admin_user_id]

    if admin_user_id.present?
      admin_user = User.find_by(id: admin_user_id)
      if admin_user
        session.delete(:admin_user_id)
        sign_in(admin_user, bypass: true)
        redirect_to admin_users_path, notice: "Returned to your admin account."
        return
      end
    end

    redirect_to root_path, alert: "No impersonation session found."
  end

  protected

  def set_blog_flash(kind, message)
    text = message.to_s.strip
    return if text.blank?

    flash[kind.to_sym] = {
      "text" => text,
      "token" => SecureRandom.hex(12)
    }
  end

  def set_current_attributes
    Current.user = current_user
    Current.request_id = request.request_id
    Current.user_agent = request.user_agent
    Current.ip_address = request.remote_ip
    Current.locale = I18n.locale
  end

  def set_locale
    raw = params[:locale] ||
          session[:locale] ||
          cookies[:locale] ||
          current_user&.locale ||
          extract_locale_from_header ||
          I18n.default_locale
    locale = LocaleTags.canonical_locale_code(raw) || I18n.default_locale.to_s
    I18n.locale = locale.to_sym if I18n.available_locales.map(&:to_s).include?(locale.to_s)
  end

  def default_url_options
    return {} if I18n.locale == I18n.default_locale

    { locale: LocaleTags.path_segment_for_canonical(I18n.locale.to_s) }
  end

  def after_sign_in_path_for(resource)
    session.delete(:user_return_to).presence || super
  end

  private

  def extract_locale_from_header
    accept_language = request.env["HTTP_ACCEPT_LANGUAGE"]
    return nil unless accept_language

    accept_language.scan(/^[a-z]{2}/).first
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    message = t("pundit.#{policy_name}.#{exception.query}", default: t("errors.unauthorized"))

    respond_to do |format|
      format.html do
        flash[:alert] = message
        redirect_back(fallback_location: root_path)
      end
      format.json { render json: { error: message }, status: :forbidden }
    end
  end

  def skip_authorization?
    devise_controller? || controller_name.in?(%w[health home locale legal]) || action_name == "stop_impersonating" || controller_path.start_with?("doorkeeper/")
  end

  def skip_pundit_verify?
    skip_authorization? || action_name == "index"
  end

  def verify_policy_scope?
    !skip_authorization? && action_name == "index"
  end

  # Configure permitted parameters for Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username first_name last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :first_name, :last_name, :avatar, :locale, :timezone, { bio_i18n: {}, display_name_i18n: {} } ])
  end

  def normalize_translatable_user_params
    return unless params[:user].is_a?(ActionController::Parameters)

    localized_display_name = params[:user].delete(:display_name_current_locale)
    return if localized_display_name.nil?

    translations = current_user&.display_name_i18n
    merged_translations = translations.is_a?(Hash) ? translations.dup : {}
    merged_translations[I18n.locale.to_s] = localized_display_name.to_s
    params[:user][:display_name_i18n] = merged_translations
  end
end
