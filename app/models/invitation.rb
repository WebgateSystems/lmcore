# frozen_string_literal: true

class Invitation < ApplicationRecord
  # Associations
  belongs_to :inviter, class_name: "User", inverse_of: :invitations_sent
  belongs_to :invitee, class_name: "User", optional: true

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending accepted expired cancelled] }
  validates :expires_at, presence: true
  validates :role_type, presence: true, inclusion: { in: %w[user author moderator admin] }
  validate :email_not_already_registered, on: :create

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :expired, -> { where(status: "expired") }
  scope :valid, -> { pending.where("expires_at > ?", Time.current) }
  scope :by_inviter, ->(user) { where(inviter: user) }

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create
  after_create :send_invitation_email

  # Class methods
  class << self
    def find_valid_by_token(token)
      valid.find_by(token: token)
    end

    def expire_old_invitations!
      pending.where("expires_at <= ?", Time.current).update_all(status: "expired")
    end
  end

  # Instance methods
  def accept!(user)
    update!(
      status: "accepted",
      invitee: user,
      accepted_at: Time.current
    )
  end

  def cancel!
    update!(status: "cancelled")
  end

  def expire!
    update!(status: "expired")
  end

  def resend!
    return false unless pending?

    update!(expires_at: 7.days.from_now)
    send_invitation_email
    true
  end

  def pending?
    status == "pending"
  end

  def accepted?
    status == "accepted"
  end

  def expired?
    status == "expired" || expires_at < Time.current
  end

  def valid_for_acceptance?
    pending? && expires_at > Time.current
  end

  def days_until_expiry
    return 0 if expired?

    [ (expires_at.to_date - Date.current).to_i, 0 ].max
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    self.expires_at ||= 7.days.from_now
  end

  def email_not_already_registered
    errors.add(:email, "is already registered") if User.exists?(email: email)
  end

  def send_invitation_email
    SendInvitationEmailWorker.perform_async(id)
  end
end
