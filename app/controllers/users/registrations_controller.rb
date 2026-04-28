# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :clamp_locale_to_blog_settings!, only: %i[edit update]
    before_action :load_pending_invitation, only: %i[new create]

    # GET /register
    def new
      build_resource(email_from_invitation_or({}))
      yield resource if block_given?
      respond_with resource
    end

    # Devise's default create then -- if the user persisted -- consume the
    # invitation so the new account immediately picks up the role assigned
    # by the inviter (e.g. moderator/editor on a specific blog).
    def create
      super do |resource|
        consume_invitation_for(resource) if resource.persisted?
      end
    end

    # Ensure profile updates always end on landing page with a visible flash.
    def update
      super do |resource|
        next unless resource.errors.empty?

        flash[:notice] = t("devise.registrations.updated", default: "Your account has been updated successfully.")
      end
    end

    protected

    def after_update_path_for(_resource)
      root_path
    end

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

    def load_pending_invitation
      token = params[:invitation_token].presence ||
              params.dig(:user, :invitation_token).presence
      return if token.blank?

      @pending_invitation = Invitation.find_valid_by_token(token)
    end

    def email_from_invitation_or(defaults)
      return defaults if @pending_invitation.nil?

      defaults.reverse_merge(email: @pending_invitation.email)
    end

    def consume_invitation_for(user)
      return if @pending_invitation.nil?
      return unless @pending_invitation.valid_for_acceptance?
      return unless @pending_invitation.email.casecmp?(user.email)

      @pending_invitation.accept!(user)
    end
  end
end
