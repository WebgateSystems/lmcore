# frozen_string_literal: true

module Dashboard
  class WorkspaceController < BaseController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def update
      requested = dashboard_workspace_options.find { |user| user.id == params.require(:blog_user_id) }

      if requested
        session[:dashboard_blog_user_id] = requested.id
        redirect_back fallback_location: dashboard_root_path,
                      notice: t("dashboard.workspace.switched", default: "Dashboard workspace changed.")
      else
        redirect_back fallback_location: dashboard_root_path,
                      alert: t("dashboard.workspace.unavailable", default: "You do not have access to that dashboard workspace.")
      end
    end
  end
end
