# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_after_action :verify_authorized, raise: false
    skip_after_action :verify_policy_scoped, raise: false

    def google_oauth2
      handle_callback("google_oauth2")
    end

    def facebook
      handle_callback("facebook")
    end

    def apple
      handle_callback("apple")
    end

    def failure
      redirect_to new_user_session_path, alert: t("auth.oauth_failed", default: "Social login failed. Please try again.")
    end

    private

    def handle_callback(provider)
      auth = request.env["omniauth.auth"]
      unless auth.present?
        redirect_to new_user_session_path, alert: t("auth.oauth_failed", default: "Social login failed. Please try again.")
        return
      end

      identity = UserIdentity.find_by(provider: provider, uid: auth.uid.to_s)

      if identity
        sign_in_and_redirect(identity.user, event: :authentication)
        return
      end

      email = auth.dig("info", "email").to_s.downcase.presence
      user = email.present? ? User.find_by("LOWER(email) = ?", email) : nil
      user ||= build_user_from_auth(auth)

      UserIdentity.create!(
        user: user,
        provider: provider,
        uid: auth.uid.to_s,
        email: email,
        data: auth.to_h
      )

      sign_in_and_redirect(user, event: :authentication)
    rescue ActiveRecord::RecordInvalid => e
      redirect_to new_user_session_path, alert: e.record.errors.full_messages.to_sentence
    end

    def build_user_from_auth(auth)
      info = auth.fetch("info", {})
      first_name = info["first_name"].presence || info["name"].to_s.split.first
      last_name = info["last_name"].presence || info["name"].to_s.split.drop(1).join(" ")
      email = info["email"].to_s.downcase.presence || fallback_email(auth)

      User.create!(
        email: email,
        first_name: first_name,
        last_name: last_name,
        username: generate_unique_username(info["nickname"] || info["name"] || email.split("@").first),
        password: Devise.friendly_token.first(24),
        confirmed_at: Time.current,
        status: "active"
      )
    end

    def fallback_email(auth)
      "#{auth.provider}-#{auth.uid}@users.libremedia.local"
    end

    def generate_unique_username(base_value)
      base = base_value.to_s.downcase.gsub(/[^a-z0-9_]/, "_").squeeze("_").sub(/\A_+/, "").sub(/_+\z/, "")
      base = "user" if base.blank?
      base = base.first(24)

      candidate = base
      suffix = 1
      while User.where("LOWER(username) = ?", candidate.downcase).exists?
        suffix += 1
        candidate = "#{base.first(24 - suffix.to_s.length)}#{suffix}"
      end

      candidate
    end
  end
end
