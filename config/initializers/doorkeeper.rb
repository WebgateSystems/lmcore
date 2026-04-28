# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record

  base_controller "DoorkeeperBaseController"
  use_polymorphic_resource_owner

  resource_owner_authenticator do
    current_user || warden.authenticate!(scope: :user)
  end

  admin_authenticator do
    current_user&.admin? || warden.authenticate!(scope: :user)
  end

  skip_authorization do |_resource_owner, client|
    client&.uid == Settings.sso.client_uid
  end

  default_scopes :openid, :profile, :email
  optional_scopes :offline_access

  enforce_configured_scopes
  force_ssl_in_redirect_uri !Rails.env.development?

  access_token_expires_in 2.hours
  use_refresh_token

  grant_flows %w[authorization_code]
end
