# frozen_string_literal: true

class Page < ApplicationRecord
  include Discard::Model
  include Sluggable
  include Translatable

  # Translations
  translates :title, :content, :meta_description, :menu_title

  # Slug configuration
  sluggable_source :title
  slug_scope :author_id

  # Associations
  belongs_to :author, class_name: "User", inverse_of: :pages
  belongs_to :published_by, class_name: "User", optional: true
  has_many :media_attachments, as: :attachable, dependent: :destroy

  # CarrierWave
  mount_uploader :featured_image, ImageUploader

  # Validations
  validates :slug, presence: true, uniqueness: { scope: :author_id }
  validates :status, presence: true, inclusion: { in: %w[draft published] }
  validates :page_type, presence: true, inclusion: { in: %w[custom about contact terms privacy] }
  validate :title_presence_for_locale
  validate :content_presence_for_locale

  # Scopes
  scope :published, -> { where(status: "published") }
  scope :draft, -> { where(status: "draft") }
  scope :in_menu, -> { where(show_in_menu: true).order(menu_position: :asc) }
  scope :by_type, ->(type) { where(page_type: type) }

  # Instance methods
  def publish!
    update!(
      status: "published",
      published_at: Time.current,
      published_by: Current.user
    )
  end

  def unpublish!
    update!(status: "draft")
  end

  def published?
    status == "published"
  end

  def draft?
    status == "draft"
  end

  def display_menu_title
    menu_title.presence || title
  end

  def system_page?
    %w[about contact terms privacy].include?(page_type)
  end

  private

  def title_presence_for_locale
    return if title_i18n.present? && title_i18n.values.any?(&:present?)

    errors.add(:title_i18n, "must have at least one translation")
  end

  def content_presence_for_locale
    return if content_i18n.present? && content_i18n.values.any?(&:present?)

    errors.add(:content_i18n, "must have at least one translation")
  end
end
