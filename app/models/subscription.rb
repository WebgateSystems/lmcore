# frozen_string_literal: true

class Subscription < ApplicationRecord
  include AASM

  # Associations
  belongs_to :user
  belongs_to :price_plan
  has_many :payments, dependent: :nullify

  # Validations
  validates :status, presence: true
  validates :started_at, presence: true

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :expired, -> { where(status: "expired") }
  scope :expiring_soon, -> { active.where("expires_at <= ?", 7.days.from_now) }
  scope :by_provider, ->(provider) { where(payment_provider: provider) }

  # State machine
  aasm column: :status, whiny_transitions: false do
    state :active, initial: true
    state :past_due
    state :cancelled
    state :expired

    event :mark_past_due do
      transitions from: :active, to: :past_due
    end

    event :reactivate do
      transitions from: %i[past_due cancelled], to: :active
    end

    event :cancel do
      before do
        self.cancelled_at = Time.current
        self.auto_renew = false
      end
      transitions from: %i[active past_due], to: :cancelled
    end

    event :expire do
      transitions from: %i[active past_due cancelled], to: :expired
    end
  end

  # Callbacks
  after_create :update_user_plan
  after_save :update_user_subscription_expiry, if: :saved_change_to_expires_at?

  # Instance methods
  def days_remaining
    return 0 unless expires_at

    [ (expires_at.to_date - Date.current).to_i, 0 ].max
  end

  def truly_expired?
    status == "expired" || (expires_at.present? && expires_at < Time.current)
  end

  def trial?
    trial_ends_at.present? && trial_ends_at > Time.current
  end

  def trial_days_remaining
    return 0 unless trial?

    [ (trial_ends_at.to_date - Date.current).to_i, 0 ].max
  end

  def renew!(new_expires_at)
    update!(
      expires_at: new_expires_at,
      status: "active"
    )
  end

  def upgrade_to(new_plan)
    update!(price_plan: new_plan)
    user.update!(price_plan: new_plan)
  end

  private

  def update_user_plan
    user.update!(
      price_plan: price_plan,
      subscription_expires_at: expires_at
    )
  end

  def update_user_subscription_expiry
    user.update!(subscription_expires_at: expires_at)
  end
end
