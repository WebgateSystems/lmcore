# frozen_string_literal: true

class Donation < ApplicationRecord
  # Associations
  belongs_to :donor, class_name: "User", optional: true, inverse_of: :donations_given
  belongs_to :recipient, class_name: "User", inverse_of: :donations_received
  belongs_to :payment, optional: true

  # Validations
  validates :amount_cents, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[EUR USD PLN UAH GBP] }
  validates :status, presence: true, inclusion: { in: %w[pending completed failed] }
  validates :donor_name, presence: true, if: -> { donor_id.nil? }
  validates :donor_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { donor_id.nil? }
  validate :cannot_donate_to_self

  # Scopes
  scope :completed, -> { where(status: "completed") }
  scope :pending, -> { where(status: "pending") }
  scope :failed, -> { where(status: "failed") }
  scope :anonymous, -> { where(anonymous: true) }
  scope :public_donations, -> { where(anonymous: false) }
  scope :recurring, -> { where(recurring: true) }
  scope :one_time, -> { where(recurring: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_recipient, ->(user) { where(recipient: user) }
  scope :from_donor, ->(user) { where(donor: user) }

  # Callbacks
  after_create :notify_recipient

  # Instance methods
  def amount
    amount_cents / 100.0
  end

  def amount=(value)
    self.amount_cents = (value.to_f * 100).round
  end

  def formatted_amount
    format("%<currency>s %<amount>.2f", currency: currency_symbol, amount: amount)
  end

  def currency_symbol
    { "EUR" => "€", "USD" => "$", "PLN" => "zł", "UAH" => "₴", "GBP" => "£" }[currency] || currency
  end

  def complete!
    update!(status: "completed")
  end

  def fail!
    update!(status: "failed")
  end

  def completed?
    status == "completed"
  end

  def display_donor_name
    return "Anonymous" if anonymous?

    donor&.full_name || donor_name
  end

  def guest_donation?
    donor_id.nil?
  end

  private

  def cannot_donate_to_self
    errors.add(:recipient, "can't donate to yourself") if donor_id.present? && donor_id == recipient_id
  end

  def notify_recipient
    CreateNotificationWorker.perform_async(
      recipient_id,
      "new_donation",
      "Donation",
      id
    )
  end
end
