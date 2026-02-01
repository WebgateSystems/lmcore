# frozen_string_literal: true

module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
  end

  def root_comments
    comments.where(parent_id: nil)
  end

  def approved_comments
    comments.where(status: "approved")
  end

  def pending_comments
    comments.where(status: "pending")
  end

  def comments_tree
    approved_comments.includes(:user, :replies).where(parent_id: nil)
  end

  def add_comment(content:, user: nil, guest_name: nil, guest_email: nil, parent: nil)
    comments.create!(
      content: content,
      user: user,
      guest_name: guest_name,
      guest_email: guest_email,
      parent: parent,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end

  private

  def update_comments_count
    update_column(:comments_count, comments.approved.count) if respond_to?(:comments_count)
  end
end
