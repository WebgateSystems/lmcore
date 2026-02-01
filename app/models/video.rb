# frozen_string_literal: true

class Video < ApplicationRecord
  include Discard::Model
  include Sluggable
  include Publishable
  include Translatable
  include Taggable
  include Commentable
  include Reactable

  # Translations
  translates :title, :subtitle, :description, :keywords, :meta_description

  # Slug configuration
  sluggable_source :title
  slug_scope :author_id

  # Associations
  belongs_to :author, class_name: "User", inverse_of: :videos
  belongs_to :category, optional: true, counter_cache: true
  belongs_to :published_by, class_name: "User", optional: true
  has_many :media_attachments, as: :attachable, dependent: :destroy
  has_many :content_visibilities, as: :visible, dependent: :destroy

  # CarrierWave
  mount_uploader :thumbnail, ImageUploader
  mount_uploader :og_image, ImageUploader
  mount_uploader :video_file, VideoUploader

  # Validations
  validates :slug, presence: true, uniqueness: { scope: :author_id }
  validates :status, presence: true, inclusion: { in: %w[draft pending scheduled published archived] }
  validates :video_provider, inclusion: { in: %w[youtube vimeo self_hosted] }, allow_nil: true
  validates :video_external_id, presence: true, if: -> { video_provider.present? && video_provider != "self_hosted" }
  validate :title_presence_for_locale
  validate :video_source_present

  # Scopes
  scope :by_author, ->(author) { where(author: author) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_provider, ->(provider) { where(video_provider: provider) }
  scope :self_hosted, -> { where(video_provider: "self_hosted") }
  scope :external, -> { where.not(video_provider: "self_hosted") }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :for_feed, -> { published.visible.includes(:author, :category, :tags).recent }

  # Video providers
  PROVIDERS = {
    "youtube" => {
      embed_url: ->(id) { "https://www.youtube.com/embed/#{id}" },
      watch_url: ->(id) { "https://www.youtube.com/watch?v=#{id}" },
      thumbnail_url: ->(id) { "https://img.youtube.com/vi/#{id}/maxresdefault.jpg" }
    },
    "vimeo" => {
      embed_url: ->(id) { "https://player.vimeo.com/video/#{id}" },
      watch_url: ->(id) { "https://vimeo.com/#{id}" },
      thumbnail_url: ->(_id) { nil } # Requires API call
    }
  }.freeze

  # Instance methods
  def embed_url
    return video_url if video_provider == "self_hosted"

    provider_config = PROVIDERS[video_provider]
    provider_config&.dig(:embed_url)&.call(video_external_id)
  end

  def watch_url
    return video_url if video_provider == "self_hosted"

    provider_config = PROVIDERS[video_provider]
    provider_config&.dig(:watch_url)&.call(video_external_id)
  end

  def external_thumbnail_url
    provider_config = PROVIDERS[video_provider]
    provider_config&.dig(:thumbnail_url)&.call(video_external_id)
  end

  def duration_formatted
    return nil unless duration_seconds

    hours = duration_seconds / 3600
    minutes = (duration_seconds % 3600) / 60
    seconds = duration_seconds % 60

    if hours.positive?
      format("%<h>d:%<m>02d:%<s>02d", h: hours, m: minutes, s: seconds)
    else
      format("%<m>d:%<s>02d", m: minutes, s: seconds)
    end
  end

  def increment_views!
    increment!(:views_count)
  end

  def self_hosted?
    video_provider == "self_hosted"
  end

  def external?
    !self_hosted?
  end

  private

  def title_presence_for_locale
    return if title_i18n.present? && title_i18n.values.any?(&:present?)

    errors.add(:title_i18n, "must have at least one translation")
  end

  def video_source_present
    return if video_url.present? || video_file.present? || video_external_id.present?

    errors.add(:base, "must have a video source (URL, file, or external ID)")
  end
end
