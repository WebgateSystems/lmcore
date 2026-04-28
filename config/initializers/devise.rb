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

  config.omniauth :google_oauth2,
                  Settings.services.oauth.google.client_id,
                  Settings.services.oauth.google.client_secret,
                  scope: "email profile",
                  access_type: "online",
                  prompt: "select_account"

  config.omniauth :facebook,
                  Settings.services.oauth.facebook.app_id,
                  Settings.services.oauth.facebook.app_secret,
                  scope: "email,public_profile",
                  info_fields: "id,name,email,first_name,last_name"

  config.omniauth :apple,
                  Settings.services.oauth.apple.client_id,
                  "",
                  scope: "name email",
                  team_id: Settings.services.oauth.apple.team_id,
                  key_id: Settings.services.oauth.apple.key_id,
                  pem: Settings.services.oauth.apple.private_key

  # Warden configuration
  config.warden do |manager|
    manager.failure_app = DeviseCustomFailure
  end
end
