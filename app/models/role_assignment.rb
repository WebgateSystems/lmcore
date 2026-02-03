# frozen_string_literal: true

class RoleAssignment < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :role
  belongs_to :scope, polymorphic: true, optional: true
  belongs_to :granted_by, class_name: "User", optional: true

  # Validations
  validates :user_id, uniqueness: { scope: %i[role_id scope_type scope_id],
                                    message: "already has this role in this scope" }

  # Scopes
  scope :global, -> { where(scope_type: nil) }
  scope :contextual, -> { where.not(scope_type: nil) }
  scope :for_blog, ->(owner) { where(scope_type: "User", scope_id: owner.id) }
  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }

  # Callbacks
  before_validation :set_granted_by, on: :create

  # Instance methods
  def global?
    scope_type.nil?
  end

  def contextual?
    scope_type.present?
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    !expired?
  end

  def blog_owner
    return nil unless scope_type == "User"

    User.find_by(id: scope_id)
  end

  private

  def set_granted_by
    self.granted_by ||= Current.user
  end
end
