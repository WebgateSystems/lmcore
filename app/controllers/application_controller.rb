# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Set current attributes for auditing and other purposes
  before_action :set_current_attributes
  before_action :set_locale

  # Pundit authorization
  after_action :verify_authorized, except: :index, unless: :skip_authorization?
  after_action :verify_policy_scoped, only: :index, unless: :skip_authorization?

  # Handle Pundit errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def set_current_attributes
    Current.user = current_user
    Current.request_id = request.request_id
    Current.user_agent = request.user_agent
    Current.ip_address = request.remote_ip
    Current.locale = I18n.locale
  end

  def set_locale
    locale = params[:locale] || current_user&.locale || extract_locale_from_header || I18n.default_locale
    I18n.locale = locale if I18n.available_locales.map(&:to_s).include?(locale.to_s)
  end

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
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
    devise_controller? || controller_name == "health"
  end

  # Configure permitted parameters for Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username first_name last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username first_name last_name bio_i18n avatar locale timezone])
  end
end
