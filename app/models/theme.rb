# frozen_string_literal: true

class Theme < ApplicationRecord
  include Sluggable

  # Slug configuration
  sluggable_source :name

  # Associations
  has_many :user_themes, dependent: :destroy
  has_many :users, through: :user_themes
  has_many :theme_accesses, dependent: :destroy
  has_many :exclusive_users, through: :theme_accesses, source: :user

  # CarrierWave
  mount_uploader :preview_image, ImageUploader

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[inactive active default] }
  validates :version, presence: true, format: { with: /\A\d+\.\d+\.\d+\z/, message: "must be in semver format (e.g., 1.0.0)" }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(status: %w[active default]) }
  scope :inactive, -> { where(status: "inactive") }
  scope :system_themes, -> { where(is_system: true) }
  scope :premium, -> { where(is_premium: true) }
  scope :free, -> { where(is_premium: false) }
  scope :ordered, -> { order(name: :asc) }
  scope :available_for, ->(user) {
    if user
      left_joins(:theme_accesses)
        .where("theme_accesses.id IS NULL OR theme_accesses.user_id = ?", user.id)
        .distinct
    else
      left_joins(:theme_accesses).where(theme_accesses: { id: nil })
    end
  }

  # Class methods
  class << self
    def default_theme
      active.detect { |theme| theme.default? && theme.template_available? } ||
        system_themes.active.detect(&:template_available?) ||
        find_by(status: "default") ||
        system_themes.active.first
    end
  end

  # Instance methods
  def price
    price_cents / 100.0
  end

  def price=(value)
    self.price_cents = (value.to_f * 100).round
  end

  def free?
    !is_premium? || price_cents.zero?
  end

  def premium?
    is_premium? && price_cents.positive?
  end

  def system?
    is_system?
  end

  def default?
    status == "default"
  end

  def active?
    %w[active default].include?(status)
  end

  def available_for?(user)
    theme_accesses.none? || (user.present? && theme_accesses.exists?(user_id: user.id))
  end

  def activate!
    update!(status: "active")
  end

  def deactivate!
    update!(status: "inactive") unless default?
  end

  def set_as_default!
    Theme.where(status: "default").update_all(status: "active")
    update!(status: "default")
  end

  def template_path
    Rails.root.join("themes", path || slug)
  end

  def template_available?
    template_path.join("layouts/application.liquid").exist? && template_path.join("index.liquid").exist?
  end

  def layout_template
    File.read(template_path.join("layout.liquid"))
  rescue Errno::ENOENT
    nil
  end

  def template_for(name)
    File.read(template_path.join("#{name}.liquid"))
  rescue Errno::ENOENT
    nil
  end

  def partial(name)
    File.read(template_path.join("partials", "#{name}.liquid"))
  rescue Errno::ENOENT
    nil
  end
end
