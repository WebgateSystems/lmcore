# frozen_string_literal: true

class UserGroupMembership < ApplicationRecord
  # Associations
  belongs_to :user_group, counter_cache: :members_count
  belongs_to :user

  # Validations
  validates :user_id, uniqueness: { scope: :user_group_id }
  validates :role, presence: true, inclusion: { in: %w[member moderator admin] }

  # Scopes
  scope :admins, -> { where(role: "admin") }
  scope :moderators, -> { where(role: %w[admin moderator]) }
  scope :regular_members, -> { where(role: "member") }

  # Instance methods
  def admin?
    role == "admin"
  end

  def moderator?
    %w[admin moderator].include?(role)
  end

  def member?
    role == "member"
  end

  def promote_to_moderator!
    update!(role: "moderator") if member?
  end

  def promote_to_admin!
    update!(role: "admin")
  end

  def demote_to_member!
    update!(role: "member") unless admin? && user_group.owner == user
  end
end
