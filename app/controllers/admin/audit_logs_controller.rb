# frozen_string_literal: true

module Admin
  class AuditLogsController < BaseController
    def index
      authorize AuditLog, policy_class: Admin::AuditLogPolicy

      logs = policy_scope(AuditLog, policy_scope_class: Admin::AuditLogPolicy::Scope)
             .includes(:user)
             .order(created_at: :desc)

      # Apply filters
      logs = logs.where(action: params[:action_type]) if params[:action_type].present?
      logs = logs.where(user_id: params[:user_id]) if params[:user_id].present?
      logs = logs.where(auditable_type: params[:resource_type]) if params[:resource_type].present?
      logs = logs.where("created_at >= ?", params[:from_date].to_date.beginning_of_day) if params[:from_date].present?
      logs = logs.where("created_at <= ?", params[:to_date].to_date.end_of_day) if params[:to_date].present?

      @pagy, @audit_logs = pagy(logs, items: params[:per_page] || 50)
      @users = User.joins(:audit_logs).distinct.order(:username)
      @action_types = AuditLog.distinct.pluck(:action).compact.sort
      @resource_types = AuditLog.distinct.pluck(:auditable_type).compact.sort
    end

    def show
      @audit_log = AuditLog.find(params[:id])
      authorize @audit_log, policy_class: Admin::AuditLogPolicy
    end
  end
end
