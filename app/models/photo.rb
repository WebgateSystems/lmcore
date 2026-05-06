# frozen_string_literal: true

class Photo < ApplicationRecord
  include Discard::Model
  include Sluggable
  include Publishable
  include Translatable
  include TitleSearchable
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
  belongs_to :album, optional: true, counter_cache: true
  belongs_to :category, optional: true, counter_cache: true
  belongs_to :published_by, class_name: "User", optional: true
  has_many :media_attachments, as: :attachable, dependent: :destroy
  has_many :content_visibilities, as: :visible, dependent: :destroy

  # CarrierWave
  mount_uploader :image, ImageUploader

  # Validations
  # Photos are intentionally low-friction to upload: only the image file is
  # required. Title/slug/description are all optional and inferred when blank
  # (see `assign_default_title_if_blank`), so the user can just drop a file
  # and submit.
  validates :slug, presence: true, uniqueness: { scope: :author_id }
  validates :image, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft pending scheduled published archived] }

  # Scopes
  scope :by_author, ->(author) { where(author: author) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :for_feed, -> { published.visible.includes(:author, :category, :tags).recent }
  scope :for_gallery, -> { where.not(album_id: nil).order(position: :asc, created_at: :asc) }

  # Callbacks
  # Title is optional in the form; if the user didn't type anything we derive
  # it from the uploaded filename so Sluggable has something to slugify.
  before_validation :assign_default_title_if_blank
  before_save :store_image_dimensions, if: :will_save_change_to_image?
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

  def assign_default_title_if_blank
    return if title_i18n.is_a?(Hash) && title_i18n.values.any?(&:present?)

    candidate = original_image_basename.presence ||
                "Photo #{Time.current.strftime('%Y-%m-%d %H:%M')}"
    self.title = candidate.to_s.tr("_-", " ").squeeze(" ").strip
  end

  def original_image_basename
    return nil unless image.present?

    raw = nil
    raw = image.file.original_filename if image.file.respond_to?(:original_filename)
    raw ||= image.identifier
    return nil if raw.blank?

    File.basename(raw.to_s, ".*").to_s
  end

  def store_image_dimensions
    return unless image.present? && image.path.present? && File.exist?(image.path)

    img = MiniMagick::Image.open(image.path)
    self.image_data = (image_data || {}).merge(
      "width" => img.width,
      "height" => img.height,
      "orientation" => img.width.to_i >= img.height.to_i ? "landscape" : "portrait"
    )
  rescue StandardError => e
    Rails.logger.warn("[Photo] failed to store image dimensions: #{e.message}")
  end

  def extract_exif_data
    ExtractExifDataWorker.perform_async(id) if image.present?
  end
end
