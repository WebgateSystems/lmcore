# frozen_string_literal: true

class Payment < ApplicationRecord
  include AASM

  # Associations
  belongs_to :user
  belongs_to :subscription, optional: true
  has_one :donation, dependent: :nullify

  # Validations
  validates :payment_provider, presence: true, inclusion: { in: %w[stripe paypal manual] }
  validates :payment_type, presence: true, inclusion: { in: %w[subscription donation theme_purchase] }
  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[EUR USD PLN UAH GBP] }
  validates :status, presence: true

  # Scopes
  scope :completed, -> { where(status: "completed") }
  scope :pending, -> { where(status: "pending") }
  scope :failed, -> { where(status: "failed") }
  scope :refunded, -> { where(status: "refunded") }
  scope :for_subscriptions, -> { where(payment_type: "subscription") }
  scope :for_donations, -> { where(payment_type: "donation") }
  scope :recent, -> { order(created_at: :desc) }
  scope :in_period, ->(start_date, end_date) { where(paid_at: start_date..end_date) }

  # State machine
  aasm column: :status, whiny_transitions: false do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed
    state :refunded

    event :process do
      transitions from: :pending, to: :processing
    end

    event :complete do
      before do
        self.paid_at = Time.current
        self.net_amount_cents = amount_cents - fee_cents
      end
      transitions from: %i[pending processing], to: :completed
    end

    event :fail do
      transitions from: %i[pending processing], to: :failed
    end

    event :refund do
      before do
        self.refunded_at = Time.current
      end
      transitions from: :completed, to: :refunded
    end
  end

  # Instance methods
  def amount
    amount_cents / 100.0
  end

  def amount=(value)
    self.amount_cents = (value.to_f * 100).round
  end

  def fee
    fee_cents / 100.0
  end

  def net_amount
    net_amount_cents / 100.0
  end

  def formatted_amount
    format("%<currency>s %<amount>.2f", currency: currency_symbol, amount: amount)
  end

  def currency_symbol
    { "EUR" => "€", "USD" => "$", "PLN" => "zł", "UAH" => "₴", "GBP" => "£" }[currency] || currency
  end

  def refundable?
    completed? && refunded_at.nil? && paid_at > 30.days.ago
  end

  def subscription_payment?
    payment_type == "subscription"
  end

  def donation_payment?
    payment_type == "donation"
  end
end
