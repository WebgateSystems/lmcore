# frozen_string_literal: true

class ContentVisibility < ApplicationRecord
  # Associations
  belongs_to :visible, polymorphic: true
  belongs_to :target, polymorphic: true

  # Validations
  validates :access_level, presence: true, inclusion: { in: %w[read comment hidden] }
  validates :target_id, uniqueness: { scope: %i[visible_type visible_id target_type] }

  # Scopes
  scope :for_content, ->(content) { where(visible: content) }
  scope :for_target, ->(target) { where(target: target) }
  scope :readable, -> { where(access_level: %w[read comment]) }
  scope :commentable, -> { where(access_level: "comment") }
  scope :hidden, -> { where(access_level: "hidden") }
  scope :for_users, -> { where(target_type: "User") }
  scope :for_groups, -> { where(target_type: "UserGroup") }

  # Class methods
  class << self
    def grant_access(content, target, level: "read")
      find_or_create_by!(visible: content, target: target) do |cv|
        cv.access_level = level
      end
    end

    def revoke_access(content, target)
      find_by(visible: content, target: target)&.destroy
    end

    def can_access?(content, user)
      return true if content_public?(content)
      return false unless user

      # Direct user access
      return true if exists?(visible: content, target: user, access_level: %w[read comment])

      # Group access
      user_group_ids = user.user_group_memberships.pluck(:user_group_id)
      exists?(
        visible: content,
        target_type: "UserGroup",
        target_id: user_group_ids,
        access_level: %w[read comment]
      )
    end

    def can_comment?(content, user)
      return false unless user

      # Direct user access
      return true if exists?(visible: content, target: user, access_level: "comment")

      # Group access
      user_group_ids = user.user_group_memberships.pluck(:user_group_id)
      exists?(
        visible: content,
        target_type: "UserGroup",
        target_id: user_group_ids,
        access_level: "comment"
      )
    end

    private

    def content_public?(content)
      !exists?(visible: content)
    end
  end

  # Instance methods
  def readable?
    %w[read comment].include?(access_level)
  end

  def commentable?
    access_level == "comment"
  end

  def hidden?
    access_level == "hidden"
  end

  def user_target?
    target_type == "User"
  end

  def group_target?
    target_type == "UserGroup"
  end
end
