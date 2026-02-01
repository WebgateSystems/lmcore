# frozen_string_literal: true

module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_create, if: :auditable?
    after_update :log_update, if: :auditable?
    after_destroy :log_destroy, if: :auditable?
  end

  class_methods do
    def auditable(enabled: true)
      @auditable = enabled
    end

    def auditable?
      @auditable != false
    end
  end

  def auditable?
    self.class.auditable?
  end

  private

  def log_create
    create_audit_log("create", {})
  end

  def log_update
    return if saved_changes.except("updated_at").empty?

    create_audit_log("update", saved_changes.except("updated_at"))
  end

  def log_destroy
    create_audit_log("destroy", attributes)
  end

  def create_audit_log(action, changes_data)
    return unless defined?(AuditLog) && AuditLog.table_exists?
    return if self.is_a?(AuditLog)

    AuditLog.create!(
      user: Current.user,
      auditable: self,
      action: action,
      changes_data: changes_data,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent,
      request_id: Current.request_id
    )
  rescue StandardError => e
    Rails.logger.error("Failed to create audit log: #{e.message}")
  end
end
