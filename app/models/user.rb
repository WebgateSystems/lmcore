# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  include Translatable

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Translations
  translates :bio

  # Associations
  belongs_to :price_plan, optional: true

  # Multi-role system
  has_many :role_assignments, dependent: :destroy
  has_many :assigned_roles, through: :role_assignments, source: :role

  # Role assignments granted by this user
  has_many :granted_role_assignments, class_name: "RoleAssignment",
                                      foreign_key: :granted_by_id,
                                      dependent: :nullify,
                                      inverse_of: :granted_by

  # Blog collaborators (users who have roles on this user's blog)
  has_many :blog_role_assignments, class_name: "RoleAssignment",
                                   foreign_key: :scope_id,
                                   dependent: :destroy,
                                   inverse_of: :scope

  has_many :posts, foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :videos, foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :photos, foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :pages, foreign_key: :author_id, dependent: :destroy, inverse_of: :author
  has_many :comments, dependent: :nullify
  has_many :reactions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :donations_given, class_name: "Donation", foreign_key: :donor_id, dependent: :nullify, inverse_of: :donor
  has_many :donations_received, class_name: "Donation", foreign_key: :recipient_id, dependent: :destroy, inverse_of: :recipient
  has_many :invitations_sent, class_name: "Invitation", foreign_key: :inviter_id, dependent: :destroy, inverse_of: :inviter
  has_many :categories, dependent: :destroy
  has_many :user_themes, dependent: :destroy
  has_many :themes, through: :user_themes
  has_many :media_attachments, dependent: :destroy
  has_many :site_settings, dependent: :destroy
  has_many :api_keys, dependent: :destroy
  has_many :audit_logs, dependent: :nullify

  # Following
  has_many :active_follows, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy, inverse_of: :follower
  has_many :passive_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy, inverse_of: :followed
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  # Groups
  has_many :owned_groups, class_name: "UserGroup", foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :user_group_memberships, dependent: :destroy
  has_many :groups, through: :user_group_memberships, source: :user_group

  # CarrierWave
  mount_uploader :avatar, AvatarUploader

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, uniqueness: { case_sensitive: false }, allow_nil: true,
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" },
                       length: { minimum: 3, maximum: 30 }
  validates :phone, uniqueness: true, allow_nil: true
  validates :status, presence: true, inclusion: { in: %w[pending active suspended deleted] }
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }, allow_nil: true
  validates :vanity_domain, uniqueness: true, allow_nil: true,
                            format: { with: /\A[a-z0-9\-\.]+\z/, message: "only allows lowercase letters, numbers, hyphens, and dots" }

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :pending, -> { where(status: "pending") }
  scope :suspended, -> { where(status: "suspended") }
  scope :with_vanity_domain, -> { where.not(vanity_domain: nil) }
  scope :verified_vanity_domain, -> { with_vanity_domain.where(vanity_domain_verified: true) }

  # Callbacks
  before_validation :set_defaults, on: :create
  before_save :normalize_email
  after_create :assign_default_plan

  # Status management
  def activate!
    update!(status: "active")
  end

  def suspend!
    update!(status: "suspended")
  end

  def soft_delete!
    update!(status: "deleted")
    discard!
  end

  # Role helpers - Multi-role system

  # Get all global roles for this user
  def global_roles
    role_assignments.global.active.includes(:role).map(&:role)
  end

  # Get all roles for a specific blog owner
  def roles_for_blog(owner)
    role_assignments.for_blog(owner).active.includes(:role).map(&:role)
  end

  # Get highest priority role (global or for specific scope)
  def highest_role(scope: nil)
    assignments = scope ? role_assignments.for_blog(scope) : role_assignments.global
    assignments.active.joins(:role).order("roles.priority DESC").first&.role
  end

  # Check if user has a specific role (global or scoped)
  def has_role?(role_slug, scope: nil)
    assignments = scope ? role_assignments.for_blog(scope) : role_assignments.global
    assignments.active.joins(:role).where(roles: { slug: role_slug }).exists?
  end

  # Check if user has any role with at least the given priority (hierarchical check)
  def has_role_with_priority?(min_priority, scope: nil)
    assignments = scope ? role_assignments.for_blog(scope) : role_assignments.global
    assignments.active.joins(:role).where("roles.priority >= ?", min_priority).exists?
  end

  # Global role checks (hierarchical)
  def super_admin?
    has_role?("super-admin")
  end

  def admin?
    super_admin? || has_role?("admin")
  end

  def author?
    has_role?("author")
  end

  def moderator?
    has_role?("moderator")
  end

  # Contextual role checks (for specific blog)
  def can_moderate?(blog_owner)
    return true if admin?
    return true if blog_owner == self
    return true if has_role?("moderator", scope: blog_owner)

    # Check hierarchical - anyone with moderator+ priority on this blog
    has_role_with_priority?(70, scope: blog_owner)
  end

  def can_edit?(blog_owner)
    return true if can_moderate?(blog_owner)
    return true if has_role?("editor", scope: blog_owner)

    # Check hierarchical - anyone with editor+ priority on this blog
    has_role_with_priority?(50, scope: blog_owner)
  end

  def can_author?(blog_owner)
    return true if can_edit?(blog_owner)
    return true if has_role?("author", scope: blog_owner)

    # Check hierarchical - anyone with author+ priority on this blog
    has_role_with_priority?(30, scope: blog_owner)
  end

  # Permission check across all roles
  def has_permission?(permission)
    # Check global roles first
    global_roles.any? { |r| r.has_permission?(permission) }
  end

  def has_permission_for_blog?(permission, blog_owner)
    # Check global admin permissions
    return true if admin? && Role.admin&.has_permission?(permission)

    # Check blog-specific roles
    roles_for_blog(blog_owner).any? { |r| r.has_permission?(permission) }
  end

  # Role assignment methods
  def assign_role!(role_or_slug, scope: nil, granted_by: nil, expires_at: nil)
    role = role_or_slug.is_a?(Role) ? role_or_slug : Role.find_by!(slug: role_or_slug)

    role_assignments.find_or_create_by!(
      role: role,
      scope_type: scope ? "User" : nil,
      scope_id: scope&.id
    ) do |assignment|
      assignment.granted_by = granted_by || Current.user
      assignment.expires_at = expires_at
    end
  end

  def remove_role!(role_or_slug, scope: nil)
    role = role_or_slug.is_a?(Role) ? role_or_slug : Role.find_by!(slug: role_or_slug)

    assignment = role_assignments.find_by(
      role: role,
      scope_type: scope ? "User" : nil,
      scope_id: scope&.id
    )
    assignment&.destroy!
  end

  def has_any_role?
    role_assignments.active.exists?
  end

  # Get all users who have roles on this user's blog
  def blog_collaborators
    User.joins(:role_assignments)
        .where(role_assignments: { scope_type: "User", scope_id: id })
        .where("role_assignments.expires_at IS NULL OR role_assignments.expires_at > ?", Time.current)
        .distinct
  end

  # Name helpers
  def full_name
    [ first_name, last_name ].compact.join(" ").presence || display_name || username || email.split("@").first
  end

  def initials
    full_name.split.map(&:first).join.upcase[0..1]
  end

  # Subscription helpers
  def current_subscription
    subscriptions.active.order(created_at: :desc).first
  end

  def subscription_active?
    subscription_expires_at.present? && subscription_expires_at > Time.current
  end

  def current_plan
    price_plan || PricePlan.default_plan
  end

  def can_create_post?
    return true if current_plan&.posts_limit.nil?

    posts_this_month < current_plan.posts_limit
  end

  def disk_space_available
    current_plan&.disk_space_bytes.to_i - disk_space_used_bytes
  end

  def disk_space_exceeded?
    disk_space_available <= 0
  end

  # Feature access
  def has_feature?(feature)
    current_plan&.has_feature?(feature)
  end

  # Following
  def follow(user)
    active_follows.create(followed: user) unless following?(user)
  end

  def unfollow(user)
    active_follows.find_by(followed: user)&.destroy
  end

  def following?(user)
    following.include?(user)
  end

  def followed_by?(user)
    followers.include?(user)
  end

  private

  def set_defaults
    self.status ||= "pending"
    self.locale ||= I18n.default_locale.to_s
    self.timezone ||= "UTC"
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def assign_default_plan
    self.price_plan ||= PricePlan.default_plan
    save(validate: false) if price_plan_id_changed?
  end
end
