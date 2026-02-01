# frozen_string_literal: true

class Theme < ApplicationRecord
  include Sluggable

  # Slug configuration
  sluggable_source :name

  # Associations
  has_many :user_themes, dependent: :destroy
  has_many :users, through: :user_themes

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

  # Class methods
  class << self
    def default_theme
      find_by(status: "default") || system_themes.active.first
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
