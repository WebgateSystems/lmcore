# frozen_string_literal: true

class PricePlan < ApplicationRecord
  include Sluggable
  include Translatable

  # Translations
  translates :name, :description

  # Associations
  has_many :users, dependent: :nullify
  has_many :subscriptions, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :currency, presence: true, inclusion: { in: %w[EUR USD PLN UAH GBP] }
  validates :billing_period, presence: true, inclusion: { in: %w[monthly yearly] }
  validates :posts_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :disk_space_mb, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc) }
  scope :free, -> { where(price_cents: 0) }
  scope :paid, -> { where("price_cents > 0") }

  # Constants
  PLANS = %w[free basic professional enterprise].freeze
  FEATURES = %w[
    basic_themes premium_themes custom_theme
    external_video self_hosted_video
    vanity_domain analytics google_analytics
    export_data advertising
    chat_access chat_documents chat_video
    forum_read forum_write forum_private
    live_viewer live_creator
    reputation_viewer reputation_moderator
    remove_branding priority_support
    delegation ai_assistant
  ].freeze

  # Class methods
  class << self
    def free_plan
      find_by(slug: "free")
    end

    def default_plan
      free_plan || first
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
    price_cents.zero?
  end

  def has_feature?(feature)
    features[feature.to_s] == true
  end

  def disk_space_bytes
    disk_space_mb * 1024 * 1024
  end

  def yearly_price_cents
    billing_period == "yearly" ? price_cents : price_cents * 12
  end

  def monthly_price_cents
    billing_period == "monthly" ? price_cents : price_cents / 12
  end
end
