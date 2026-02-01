# frozen_string_literal: true

class UserGroup < ApplicationRecord
  include Sluggable
  include Translatable

  # Translations
  translates :description

  # Slug configuration
  sluggable_source :name
  slug_scope :owner_id

  # Associations
  belongs_to :owner, class_name: "User", inverse_of: :owned_groups
  has_many :user_group_memberships, dependent: :destroy
  has_many :members, through: :user_group_memberships, source: :user
  has_many :content_visibilities, as: :target, dependent: :destroy

  # CarrierWave
  mount_uploader :cover_image, ImageUploader

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :owner_id }
  validates :visibility, presence: true, inclusion: { in: %w[private public] }

  # Scopes
  scope :public_groups, -> { where(visibility: "public") }
  scope :private_groups, -> { where(visibility: "private") }
  scope :by_owner, ->(user) { where(owner: user) }
  scope :with_member, ->(user) { joins(:user_group_memberships).where(user_group_memberships: { user: user }) }

  # Callbacks
  after_create :add_owner_as_admin

  # Instance methods
  def public?
    visibility == "public"
  end

  def private?
    visibility == "private"
  end

  def add_member(user, role: "member")
    user_group_memberships.find_or_create_by!(user: user) do |membership|
      membership.role = role
    end
  end

  def remove_member(user)
    return false if user == owner

    user_group_memberships.find_by(user: user)&.destroy
  end

  def member?(user)
    members.include?(user)
  end

  def admin?(user)
    user == owner || user_group_memberships.exists?(user: user, role: "admin")
  end

  def moderator?(user)
    admin?(user) || user_group_memberships.exists?(user: user, role: "moderator")
  end

  def set_role(user, role)
    membership = user_group_memberships.find_by(user: user)
    membership&.update!(role: role)
  end

  def transfer_ownership(new_owner)
    return false unless member?(new_owner)

    transaction do
      set_role(owner, "admin")
      update!(owner: new_owner)
      set_role(new_owner, "admin")
    end
    true
  end

  private

  def add_owner_as_admin
    add_member(owner, role: "admin")
  end
end
