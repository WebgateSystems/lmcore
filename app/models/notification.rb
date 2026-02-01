# frozen_string_literal: true

class Notification < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :notification_type, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }
  scope :unsent, -> { where(sent_at: nil) }

  # Notification types
  TYPES = %w[
    new_comment
    comment_reply
    new_follower
    new_donation
    post_published
    post_featured
    mention
    subscription_expiring
    subscription_expired
    payment_received
    payment_failed
    welcome
    system
  ].freeze

  # Class methods
  class << self
    def mark_all_as_read!(user)
      where(user: user).unread.update_all(read_at: Time.current)
    end

    def unread_count(user)
      where(user: user).unread.count
    end

    def create_notification(user:, type:, actor: nil, notifiable: nil, data: {})
      create!(
        user: user,
        actor: actor,
        notifiable: notifiable,
        notification_type: type,
        data: data
      )
    end
  end

  # Instance methods
  def read!
    update!(read_at: Time.current) unless read?
  end

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def mark_as_sent!(method = "in_app")
    update!(sent_at: Time.current, delivery_method: method)
  end

  def sent?
    sent_at.present?
  end

  def title
    I18n.t("notifications.#{notification_type}.title", **data.symbolize_keys.merge(default: notification_type.humanize))
  end

  def message
    I18n.t("notifications.#{notification_type}.message", **data.symbolize_keys.merge(default: ""))
  end

  def icon
    case notification_type
    when "new_comment", "comment_reply" then "comment"
    when "new_follower" then "user-plus"
    when "new_donation" then "heart"
    when "post_published", "post_featured" then "file-text"
    when "mention" then "at-sign"
    when "subscription_expiring", "subscription_expired" then "alert-circle"
    when "payment_received", "payment_failed" then "credit-card"
    else "bell"
    end
  end

  def url
    case notification_type
    when "new_comment", "comment_reply"
      notifiable.is_a?(Comment) ? polymorphic_path(notifiable.commentable) : nil
    when "new_follower"
      actor ? user_path(actor) : nil
    when "post_published", "post_featured"
      notifiable.is_a?(Post) ? post_path(notifiable) : nil
    else
      nil
    end
  end

  private

  def polymorphic_path(record)
    "/#{record.class.name.underscore.pluralize}/#{record.slug}"
  end

  def user_path(user)
    "/@#{user.username}"
  end

  def post_path(post)
    "/posts/#{post.slug}"
  end
end
