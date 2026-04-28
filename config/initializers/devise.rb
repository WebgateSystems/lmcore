# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = Settings.services.smtp.from
  config.mailer = "CustomDeviseMailer"

  require "devise/orm/active_record"

  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [ :http_auth ]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  # Lockable
  config.lock_strategy = :failed_attempts
  config.unlock_keys = [ :email ]
  config.unlock_strategy = :both
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
  config.last_attempt_warning = true

  # JWT Configuration
  config.jwt do |jwt|
    jwt.secret = Settings.devise_jwt_secret_key
    jwt.dispatch_requests = [
      [ "POST", %r{^/api/v1/auth/sign_in$} ],
      [ "POST", %r{^/api/v1/auth/sign_up$} ]
    ]
    jwt.revocation_requests = [
      [ "DELETE", %r{^/api/v1/auth/sign_out$} ]
    ]
    jwt.expiration_time = 24.hours.to_i
  end

  # Navigational formats (include html for web forms)
  config.navigational_formats = [ "*/*", :html, :turbo_stream ]

  # Use parent controller for layout
  config.parent_controller = "DeviseParentController"

  google_client_id = Settings.services.oauth.google.client_id.to_s
  google_client_secret = Settings.services.oauth.google.client_secret.to_s
  google_placeholder = google_client_id == "google-client-id.apps.googleusercontent.com" ||
                       google_client_secret == "google-client-secret"

  if (google_client_id.present? && google_client_secret.present? && !google_placeholder) || Rails.env.test?
    config.omniauth :google_oauth2,
                    google_client_id,
                    google_client_secret,
                    scope: "email profile",
                    access_type: "online",
                    prompt: "select_account"
  else
    Rails.logger.warn("[devise] Google OAuth disabled due to missing placeholder credentials")
  end

  facebook_app_id = Settings.services.oauth.facebook.app_id.to_s
  facebook_app_secret = Settings.services.oauth.facebook.app_secret.to_s
  facebook_placeholder = facebook_app_id == "facebook-app-id" ||
                         facebook_app_secret == "facebook-app-secret"

  if (facebook_app_id.present? && facebook_app_secret.present? && !facebook_placeholder) || Rails.env.test?
    config.omniauth :facebook,
                    facebook_app_id,
                    facebook_app_secret,
                    scope: "email,public_profile",
                    info_fields: "id,name,email,first_name,last_name"
  else
    Rails.logger.warn("[devise] Facebook OAuth disabled due to missing placeholder credentials")
  end

  apple_client_id = Settings.services.oauth.apple.client_id.to_s
  apple_team_id = Settings.services.oauth.apple.team_id.to_s
  apple_key_id = Settings.services.oauth.apple.key_id.to_s
  apple_private_key = Settings.services.oauth.apple.private_key.to_s

  if (apple_client_id.present? && apple_team_id.present? && apple_key_id.present? && apple_private_key.present? &&
     !apple_private_key.include?("replace-with-apple-private-key")) || Rails.env.test?
    begin
      # Omniauth Apple requires a valid EC private key (P-256). If invalid,
      # skip strategy registration to avoid runtime failures on /auth/apple.
      ec_key = OpenSSL::PKey::EC.new(apple_private_key)
      raise OpenSSL::PKey::ECError, "missing curve name" if ec_key.group&.curve_name.blank?

      config.omniauth :apple,
                      apple_client_id,
                      "",
                      scope: "name email",
                      team_id: apple_team_id,
                      key_id: apple_key_id,
                      pem: apple_private_key
    rescue OpenSSL::PKey::ECError, OpenSSL::PKey::PKeyError => e
      Rails.logger.warn("[devise] Apple OAuth disabled due to invalid private key: #{e.message}")
    end
  else
    Rails.logger.warn("[devise] Apple OAuth disabled due to missing placeholder credentials")
  end

  # Warden configuration
  config.warden do |manager|
    manager.failure_app = DeviseCustomFailure
  end
end
