# frozen_string_literal: true

class Photo < ApplicationRecord
  include Discard::Model
  include Sluggable
  include Publishable
  include Translatable
  include Taggable
  include Commentable
  include Reactable

  # Translations
  translates :title, :description, :alt_text, :keywords

  # Slug configuration
  sluggable_source :title
  slug_scope :author_id

  # Associations
  belongs_to :author, class_name: "User", inverse_of: :photos
  belongs_to :category, optional: true, counter_cache: true
  belongs_to :published_by, class_name: "User", optional: true
  has_many :media_attachments, as: :attachable, dependent: :destroy
  has_many :content_visibilities, as: :visible, dependent: :destroy

  # CarrierWave
  mount_uploader :image, ImageUploader

  # Validations
  validates :slug, presence: true, uniqueness: { scope: :author_id }
  validates :image, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft pending scheduled published archived] }
  validate :title_presence_for_locale

  # Scopes
  scope :by_author, ->(author) { where(author: author) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :for_feed, -> { published.visible.includes(:author, :category, :tags).recent }
  scope :for_gallery, -> { published.visible.order(position: :asc, created_at: :desc) }

  # Callbacks
  after_save :extract_exif_data, if: :saved_change_to_image?

  # Instance methods
  def increment_views!
    increment!(:views_count)
  end

  def dimensions
    return nil unless image_data.present?

    { width: image_data["width"], height: image_data["height"] }
  end

  def aspect_ratio
    dims = dimensions
    return nil unless dims && dims[:width] && dims[:height]

    dims[:width].to_f / dims[:height]
  end

  def landscape?
    aspect_ratio && aspect_ratio > 1
  end

  def portrait?
    aspect_ratio && aspect_ratio < 1
  end

  def square?
    aspect_ratio && (aspect_ratio - 1).abs < 0.1
  end

  def camera_info
    return nil unless exif_data.present?

    {
      make: exif_data["make"],
      model: exif_data["model"],
      lens: exif_data["lens"],
      focal_length: exif_data["focal_length"],
      aperture: exif_data["aperture"],
      shutter_speed: exif_data["shutter_speed"],
      iso: exif_data["iso"],
      taken_at: exif_data["date_time_original"]
    }.compact
  end

  def location_info
    return nil unless exif_data.present?

    {
      latitude: exif_data["gps_latitude"],
      longitude: exif_data["gps_longitude"],
      altitude: exif_data["gps_altitude"]
    }.compact.presence
  end

  private

  def title_presence_for_locale
    return if title_i18n.present? && title_i18n.values.any?(&:present?)

    errors.add(:title_i18n, "must have at least one translation")
  end

  def extract_exif_data
    ExtractExifDataWorker.perform_async(id) if image.present?
  end
end
