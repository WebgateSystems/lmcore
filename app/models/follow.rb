# frozen_string_literal: true

class Follow < ApplicationRecord
  # Associations
  belongs_to :follower, class_name: "User", inverse_of: :active_follows
  belongs_to :followed, class_name: "User", inverse_of: :passive_follows

  # Validations
  validates :follower_id, uniqueness: { scope: :followed_id }
  validates :status, presence: true, inclusion: { in: %w[active muted blocked] }
  validate :cannot_follow_self

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :muted, -> { where(status: "muted") }
  scope :blocked, -> { where(status: "blocked") }

  # Callbacks
  after_create :notify_followed_user
  after_create :update_follower_counts
  after_destroy :update_follower_counts

  # Instance methods
  def mute!
    update!(status: "muted")
  end

  def unmute!
    update!(status: "active")
  end

  def block!
    update!(status: "blocked")
  end

  def unblock!
    update!(status: "active")
  end

  def active?
    status == "active"
  end

  def muted?
    status == "muted"
  end

  def blocked?
    status == "blocked"
  end

  private

  def cannot_follow_self
    errors.add(:follower, "can't follow yourself") if follower_id == followed_id
  end

  def notify_followed_user
    CreateNotificationWorker.perform_async(
      followed_id,
      "new_follower",
      "User",
      follower_id
    )
  end

  def update_follower_counts
    # Could update counter caches if we add them to users table
  end
end
