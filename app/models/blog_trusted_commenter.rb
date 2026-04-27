# frozen_string_literal: true

class BlogTrustedCommenter < ApplicationRecord
  belongs_to :blog_owner, class_name: "User", inverse_of: :trusted_commenters
  belongs_to :user, inverse_of: :blog_trusted_commenterships
  belongs_to :granted_by, class_name: "User", inverse_of: :trusted_commenters_granted, optional: true

  validates :user_id, uniqueness: { scope: :blog_owner_id }
  validate :cannot_trust_blog_owner

  scope :for_blog, ->(owner) { where(blog_owner: owner) }

  private

  def cannot_trust_blog_owner
    return unless blog_owner_id.present? && user_id.present?
    return unless blog_owner_id == user_id

    errors.add(:user, "cannot be blog owner")
  end
end
