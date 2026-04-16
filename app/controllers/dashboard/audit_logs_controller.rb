# frozen_string_literal: true

module Dashboard
  class AuditLogsController < BaseController
    before_action :require_moderator!

    def index
      authorize AuditLog, policy_class: Dashboard::AuditLogPolicy
      logs = policy_scope(AuditLog, policy_scope_class: Dashboard::AuditLogPolicy::Scope)
             .recent.includes(:user)
      logs = logs.by_action(params[:action_filter]) if params[:action_filter].present?
      @pagy, @audit_logs = pagy(logs, items: 30)
    end

    def show
      @audit_log = AuditLog.find(params[:id])
      authorize @audit_log, policy_class: Dashboard::AuditLogPolicy
    end
  end
end
