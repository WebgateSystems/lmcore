# frozen_string_literal: true

def oidc_signing_rsa_key
  raw = Settings.sso.oidc_signing_key.to_s
  if raw.blank?
    Rails.logger.warn("[OIDC] Empty sso.oidc_signing_key in settings.yml. Falling back to ephemeral key.")
    return OpenSSL::PKey::RSA.generate(2048)
  end

  OpenSSL::PKey::RSA.new(raw)
rescue OpenSSL::PKey::RSAError
  Rails.logger.warn("[OIDC] Invalid sso.oidc_signing_key in settings.yml. Falling back to ephemeral key.")
  OpenSSL::PKey::RSA.generate(2048)
end

Doorkeeper::OpenidConnect.configure do
  issuer do
    Settings.sso.issuer
  end

  signing_key oidc_signing_rsa_key || OpenSSL::PKey::RSA.generate(2048)

  subject_types_supported [ :public ]

  resource_owner_from_access_token do |access_token|
    User.find(access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |_resource_owner|
    Time.current
  end

  reauthenticate_resource_owner do |_resource_owner, _return_to|
    false
  end

  claims do
    normal_claim :sub, response: %i[id_token user_info] do |resource_owner, _scopes, _|
      resource_owner.id
    end

    normal_claim :email, response: %i[id_token user_info], scope: :email do |resource_owner|
      resource_owner.email
    end

    normal_claim :email_verified, response: %i[id_token user_info], scope: :email do |resource_owner|
      resource_owner.confirmed?
    end

    normal_claim :name, response: %i[id_token user_info], scope: :profile do |resource_owner|
      resource_owner.full_name
    end

    normal_claim :preferred_username, response: %i[id_token user_info], scope: :profile do |resource_owner|
      resource_owner.username
    end
  end
end
