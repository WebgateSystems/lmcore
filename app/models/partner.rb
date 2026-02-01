# frozen_string_literal: true

class Partner < ApplicationRecord
  include Sluggable
  include Translatable

  # Translations
  translates :description

  # Slug configuration
  sluggable_source :name

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :ordered, -> { order(position: :asc) }

  # Instance methods
  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  def logo
    logo_svg.presence || logo_url
  end

  def has_logo?
    logo_svg.present? || logo_url.present?
  end

  def svg_logo?
    logo_svg.present?
  end
end
