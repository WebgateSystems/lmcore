# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :clamp_locale_to_blog_settings!, only: %i[edit update]

    protected

    def clamp_locale_to_blog_settings!
      return unless user_signed_in?

      allowed = SiteSetting.blog_available_locale_codes_for(current_user)
      cur = I18n.locale.to_s
      return if allowed.include?(cur)

      I18n.locale = (allowed.include?("en") ? "en" : allowed.first).to_sym
    end

    def update_resource(resource, params)
      # Devise 5's update_without_password no longer strips :current_password; passing it
      # hits ActiveRecord as an unknown attribute (only attr_reader exists). Normalize keys
      # so Devise's delete(:password) calls match form submissions.
      attrs = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
      attrs = attrs.deep_symbolize_keys
      attempting_password_change = attrs[:password].present? || attrs[:password_confirmation].present?

      if attempting_password_change
        resource.update_with_password(attrs)
      else
        attrs.delete(:current_password)
        resource.update_without_password(attrs)
      end
    end

    def account_update_params
      permitted = devise_parameter_sanitizer.sanitize(:account_update)
      return permitted if resource.super_admin?

      permitted = permitted.except(:username)
      sanitize_user_locale_param!(permitted)
      permitted
    end

    def sanitize_user_locale_param!(permitted)
      return if permitted[:locale].blank?

      allowed = SiteSetting.blog_available_locale_codes_for(resource)
      loc = permitted[:locale].to_s
      permitted[:locale] = allowed.include?(loc) ? loc : (allowed.include?("en") ? "en" : allowed.first)
    end
  end
end
