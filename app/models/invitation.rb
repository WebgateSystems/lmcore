# frozen_string_literal: true

class Invitation < ApplicationRecord
  # Roles that a blog owner is allowed to delegate to invited collaborators.
  # The blog owner is themselves the "author" of the blog -- you cannot grant
  # somebody else the author role on your blog. Anything more powerful (admin,
  # super-admin) belongs to the platform admin panel.
  BLOG_ROLE_SLUGS = %w[moderator editor contributor].freeze

  # Associations
  belongs_to :inviter, class_name: "User", inverse_of: :invitations_sent
  belongs_to :invitee, class_name: "User", optional: true
  belongs_to :blog_owner, class_name: "User", optional: true

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending accepted expired cancelled] }
  validates :expires_at, presence: true
  validates :role_type, presence: true, inclusion: { in: %w[user author moderator admin] }
  validates :blog_role_slug, inclusion: { in: BLOG_ROLE_SLUGS }, allow_nil: true
  validate :blog_role_requires_blog_owner
  validate :email_not_already_registered, on: :create, unless: :blog_invitation?
  validate :email_not_already_team_member, on: :create, if: :blog_invitation?

  # Scopes
  scope :pending, -> { where(status: "pending") }
  scope :accepted, -> { where(status: "accepted") }
  scope :expired, -> { where(status: "expired") }
  scope :valid, -> { pending.where("expires_at > ?", Time.current) }
  scope :by_inviter, ->(user) { where(inviter: user) }
  scope :for_blog, ->(owner) { where(blog_owner_id: owner.id) }

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

  # Marks the invitation as accepted, links the new user as `invitee`, and --
  # if this is a blog-team invitation -- grants the requested role on the
  # blog owner's scope. Idempotent within a single call.
  def accept!(user)
    transaction do
      update!(
        status: "accepted",
        invitee: user,
        accepted_at: Time.current
      )
      grant_blog_role!(user) if blog_invitation?
    end
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

  def blog_invitation?
    blog_owner_id.present? && blog_role_slug.present?
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

  # For team invitations we DO want to allow inviting an existing user (the
  # invitation is then a team-add request, not a registration request). We
  # only block re-inviting somebody who is already a collaborator.
  def email_not_already_team_member
    return unless blog_owner

    user = User.find_by(email: email)
    return unless user

    already = RoleAssignment.for_blog(blog_owner).active.exists?(user_id: user.id)
    errors.add(:email, "is already a team member of this blog") if already
  end

  def blog_role_requires_blog_owner
    return if blog_role_slug.blank? && blog_owner_id.blank?
    return if blog_role_slug.present? && blog_owner_id.present?

    errors.add(:blog_role_slug, "must be paired with a blog owner")
  end

  def grant_blog_role!(user)
    role = Role.find_by(slug: blog_role_slug)
    return unless role && blog_owner

    user.assign_role!(role, scope: blog_owner, granted_by: inviter)
  end

  def send_invitation_email
    SendInvitationEmailWorker.perform_async(id)
  end
end
