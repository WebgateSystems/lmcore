# frozen_string_literal: true

class Comment < ApplicationRecord
  include Discard::Model
  include Reactable

  # Associations
  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :parent, class_name: "Comment", optional: true, counter_cache: :replies_count
  belongs_to :approved_by, class_name: "User", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  # Validations
  validates :content, presence: true, length: { minimum: 1, maximum: 10_000 }
  validates :status, presence: true, inclusion: { in: %w[pending approved spam deleted] }
  validates :guest_name, presence: true, if: -> { user_id.nil? }
  validates :guest_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { user_id.nil? }
  validate :parent_must_belong_to_same_commentable

  # Scopes
  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }
  scope :spam, -> { where(status: "spam") }
  scope :root_comments, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :by_user, ->(user) { where(user: user) }

  # Callbacks
  before_create :set_pending_status
  after_create :notify_author
  after_update :update_commentable_count, if: :saved_change_to_status?

  # Instance methods
  def approve!(moderator = nil)
    update!(
      status: "approved",
      approved_at: Time.current,
      approved_by: moderator
    )
  end

  def mark_as_spam!
    update!(status: "spam")
  end

  def reject!
    update!(status: "deleted")
    discard!
  end

  def approved?
    status == "approved"
  end

  def pending?
    status == "pending"
  end

  def spam?
    status == "spam"
  end

  def author_name
    user&.full_name || guest_name
  end

  def author_email
    user&.email || guest_email
  end

  def reply?
    parent_id.present?
  end

  def root_comment
    reply? ? parent.root_comment : self
  end

  def depth
    reply? ? parent.depth + 1 : 0
  end

  def reply_to(content:, user: nil, guest_name: nil, guest_email: nil)
    replies.create!(
      content: content,
      user: user,
      guest_name: guest_name,
      guest_email: guest_email,
      commentable: commentable,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end

  private

  def set_pending_status
    self.status ||= "pending"
  end

  def parent_must_belong_to_same_commentable
    return unless parent.present?
    return if parent.commentable_type == commentable_type && parent.commentable_id == commentable_id

    errors.add(:parent, "must belong to the same content")
  end

  def notify_author
    NotifyCommentAuthorWorker.perform_async(id)
  end

  def update_commentable_count
    commentable.update_column(:comments_count, commentable.comments.approved.count)
  end
end
