# frozen_string_literal: true

class SsoController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  skip_before_action :authenticate_user!, raise: false

  def login
    callback_uri = sso_callback_url(host: request.host, protocol: request.protocol)
    Sso::ClientApplication.ensure_for_redirect!(callback_uri)

    session[:sso_return_to] = sanitized_return_to
    session[:sso_state] = SecureRandom.hex(24)
    session[:sso_nonce] = SecureRandom.hex(24)

    redirect_to authorization_endpoint_url(callback_uri), allow_other_host: true
  end

  def callback
    unless valid_state?
      redirect_to root_path, alert: t("auth.sso_state_mismatch", default: "Invalid SSO state. Please retry login.")
      return
    end

    callback_uri = sso_callback_url(host: request.host, protocol: request.protocol)
    Sso::ClientApplication.ensure_for_redirect!(callback_uri)

    token = exchange_authorization_code(callback_uri)
    if token.blank?
      redirect_to new_user_session_path, alert: t("auth.sso_failed", default: "SSO sign in failed.")
      return
    end

    access_token = Doorkeeper::AccessToken.find_by(token: token)
    if access_token.blank? || access_token.revoked? || access_token.expired?
      redirect_to new_user_session_path, alert: t("auth.sso_failed", default: "SSO sign in failed.")
      return
    end

    user = User.find_by(id: access_token.resource_owner_id, status: "active")
    if user.blank?
      redirect_to new_user_session_path, alert: t("auth.sso_user_not_found", default: "Could not map SSO user.")
      return
    end

    sign_in(:user, user)
    redirect_to(session.delete(:sso_return_to).presence || root_path)
  end

  def logout
    sign_out(current_user) if current_user
    redirect_to root_path
  end

  private

  def authorization_endpoint_url(callback_uri)
    params = {
      response_type: "code",
      client_id: Settings.sso.client_uid,
      redirect_uri: callback_uri,
      scope: "openid profile email",
      state: session[:sso_state],
      nonce: session[:sso_nonce]
    }

    "#{Settings.sso.issuer}/oauth/authorize?#{Rack::Utils.build_query(params)}"
  end

  def exchange_authorization_code(callback_uri)
    response = Faraday.post(
      "#{Settings.sso.issuer}/oauth/token",
      {
        grant_type: "authorization_code",
        code: params[:code],
        redirect_uri: callback_uri,
        client_id: Settings.sso.client_uid,
        client_secret: Settings.sso.client_secret
      },
      "Content-Type" => "application/x-www-form-urlencoded"
    )
    return nil unless response.success?

    JSON.parse(response.body).fetch("access_token", nil)
  rescue StandardError
    nil
  end

  def valid_state?
    expected = session.delete(:sso_state).to_s
    provided = params[:state].to_s
    expected.present? && provided.present? && ActiveSupport::SecurityUtils.secure_compare(expected, provided)
  end

  def sanitized_return_to
    path = params[:return_to].to_s
    return root_path if path.blank?
    return root_path unless path.start_with?("/")
    return root_path if path.start_with?("//")

    path
  end
end
