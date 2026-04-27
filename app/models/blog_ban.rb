# frozen_string_literal: true

class BlogBan < ApplicationRecord
  belongs_to :blog_owner, class_name: "User", inverse_of: :blog_bans_received
  belongs_to :user, inverse_of: :blog_bans
  belongs_to :banned_by, class_name: "User", inverse_of: :blog_bans_granted, optional: true

  validates :reason, presence: true, length: { minimum: 3, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :blog_owner_id }
  validate :cannot_ban_self

  scope :active, -> { where(active: true) }
  scope :for_blog, ->(owner) { where(blog_owner: owner) }
  scope :for_user, ->(user) { where(user: user) }

  private

  def cannot_ban_self
    return unless blog_owner_id.present? && user_id.present?
    return unless blog_owner_id == user_id

    errors.add(:user, "cannot be blog owner")
  end
end
