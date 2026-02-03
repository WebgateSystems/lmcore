# frozen_string_literal: true

class Role < ApplicationRecord
  include Sluggable
  include Translatable

  # Translations
  translates :name, :description

  # Associations
  has_many :role_assignments, dependent: :destroy
  has_many :users, through: :role_assignments, source: :user

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :priority, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :system_roles, -> { where(system_role: true) }
  scope :custom_roles, -> { where(system_role: false) }
  scope :ordered, -> { order(priority: :desc) }

  # Constants
  SYSTEM_ROLES = %w[super_admin admin moderator author user guest].freeze

  # Class methods
  class << self
    def super_admin
      find_by(slug: "super-admin")
    end

    def admin
      find_by(slug: "admin")
    end

    def moderator
      find_by(slug: "moderator")
    end

    def author
      find_by(slug: "author")
    end

    def user
      find_by(slug: "user")
    end

    def guest
      find_by(slug: "guest")
    end
  end

  # Instance methods
  def has_permission?(permission)
    permissions.include?(permission.to_s) || permissions.include?("*")
  end

  def add_permission(permission)
    self.permissions = (permissions + [ permission.to_s ]).uniq
  end

  def remove_permission(permission)
    self.permissions = permissions - [ permission.to_s ]
  end

  def system?
    system_role?
  end
end
