# frozen_string_literal: true

class AuditLog < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true

  # Validations
  validates :action, presence: true
  validates :auditable_type, presence: true
  validates :auditable_id, presence: true

  # Disable auditing for this model (prevent infinite loop)
  auditable enabled: false

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user) { where(user: user) }
  scope :for_record, ->(record) { where(auditable: record) }
  scope :creates, -> { where(action: "create") }
  scope :updates, -> { where(action: "update") }
  scope :destroys, -> { where(action: "destroy") }
  scope :in_period, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Actions
  ACTIONS = %w[create update destroy login logout password_reset confirm suspend activate].freeze

  # Class methods
  class << self
    def log(action:, auditable:, user: nil, changes_data: {}, metadata: {})
      create!(
        action: action,
        auditable: auditable,
        user: user || Current.user,
        changes_data: changes_data,
        metadata: metadata,
        ip_address: Current.ip_address,
        user_agent: Current.user_agent,
        request_id: Current.request_id
      )
    end

    def cleanup_old_logs!(older_than: 1.year.ago)
      where("created_at < ?", older_than).delete_all
    end
  end

  # Instance methods
  def changed_fields
    changes_data.keys
  end

  def previous_value(field)
    change = changes_data[field.to_s]
    change.is_a?(Array) ? change[0] : nil
  end

  def new_value(field)
    change = changes_data[field.to_s]
    change.is_a?(Array) ? change[1] : change
  end

  def create?
    action == "create"
  end

  def update?
    action == "update"
  end

  def destroy?
    action == "destroy"
  end

  def description
    case action
    when "create" then "Created #{auditable_type.underscore.humanize}"
    when "update" then "Updated #{auditable_type.underscore.humanize}: #{changed_fields.join(', ')}"
    when "destroy" then "Deleted #{auditable_type.underscore.humanize}"
    else action.humanize
    end
  end
end
