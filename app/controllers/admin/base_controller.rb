# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :authenticate_user!
    before_action :require_admin!

    # Skip locale-based routing for admin
    skip_before_action :set_locale

    protected

    def require_admin!
      return if current_user&.admin?

      flash[:alert] = t("errors.admin_required", default: "You must be an administrator to access this area.")
      redirect_to root_path
    end

    def require_super_admin!
      return if current_user&.super_admin?

      flash[:alert] = t("errors.super_admin_required", default: "You must be a super administrator to perform this action.")
      redirect_to admin_root_path
    end

    # Override Pundit's skip conditions for admin namespace
    def skip_pundit_verify?
      false
    end

    def verify_policy_scope?
      action_name == "index"
    end

    # Default URL options without locale for admin
    def default_url_options
      {}
    end
  end
end
