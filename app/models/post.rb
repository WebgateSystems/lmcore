# frozen_string_literal: true

class Post < ApplicationRecord
  include Discard::Model
  include Sluggable
  include Publishable
  include Translatable
  include TitleSearchable
  include Taggable
  include Commentable
  include Reactable

  # Translations
  # NOTE: `content_i18n` holds the rendered+sanitized HTML ready for Liquid templates.
  # `content_source_i18n` holds the original input (HTML or Markdown depending on
  # `content_format`). The renderer is run in `before_save` so the public blog never
  # has to call it on read.
  translates :title, :subtitle, :lead, :content, :content_source, :keywords, :meta_description

  # Slug configuration
  sluggable_source :title
  slug_scope :author_id

  # Associations
  belongs_to :author, class_name: "User", inverse_of: :posts
  belongs_to :category, optional: true, counter_cache: true
  belongs_to :published_by, class_name: "User", optional: true
  belongs_to :video, optional: true
  has_many :media_attachments, as: :attachable, dependent: :destroy
  has_many :content_visibilities, as: :visible, dependent: :destroy
  has_many :dashboard_job_runs, dependent: :nullify

  # CarrierWave
  mount_uploader :featured_image, ImageUploader
  mount_uploader :og_image, ImageUploader

  # Validations
  validates :slug, presence: true, uniqueness: { scope: :author_id }
  validates :status, presence: true, inclusion: { in: %w[draft pending scheduled published archived] }
  validates :content_format, inclusion: { in: %w[html markdown] }, allow_nil: false
  validate :title_presence_for_locale
  validate :content_presence_for_locale

  # Scopes
  scope :by_author, ->(author) { where(author: author) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :for_feed, -> { published.visible.includes(:author, :category, :tags).recent }

  # Callbacks
  before_save :rerender_content_per_locale!, if: :should_rerender_content?
  after_save :update_author_posts_count, if: :saved_change_to_status?

  # Search (pg_search)
  include PgSearch::Model
  pg_search_scope :search_content,
                  against: %i[title_i18n content_i18n lead_i18n keywords_i18n],
                  using: {
                    tsearch: { prefix: true, dictionary: "simple" }
                  }

  # Instance methods
  def reading_time
    words_per_minute = 200
    content_text = content.to_s.gsub(/<[^>]*>/, "") # Strip HTML
    word_count = content_text.split.size
    (word_count / words_per_minute.to_f).ceil
  end

  def increment_views!
    increment!(:views_count)
  end

  def related_posts(limit: 5)
    return Post.none if tags.empty?

    Post.published
        .visible
        .joins(:tags)
        .where(tags: { id: tag_ids })
        .where.not(id: id)
        .group(:id)
        .order("COUNT(tags.id) DESC")
        .limit(limit)
  end

  def visible_to?(user)
    return true if published? && content_visibilities.empty?
    return true if author == user
    return false unless user

    content_visibilities.exists?(target: user) ||
      content_visibilities.joins("INNER JOIN user_group_memberships ON content_visibilities.target_id = user_group_memberships.user_group_id")
                          .where(target_type: "UserGroup", user_group_memberships: { user_id: user.id })
                          .exists?
  end

  # Inline images rendered inside the post body (placeholders
  # `<figure data-attachment-id="UUID">` resolved by Posts::ContentRenderer).
  def inline_images
    media_attachments.where(attachment_type: "image").order(:position)
  end

  # Files attached to the post, displayed under the body as a download list
  # (PDFs etc.).
  def documents
    media_attachments.where(attachment_type: "document").order(:position)
  end

  # URL of the original article on the source site, when the post was
  # imported from a known external source. Returns `nil` for organic posts
  # so the public template falls back to plain text source name.
  #
  # Per-source rules:
  #   * `ukr_pravda_blog` — `external_id` is stored as `"<author_slug>/<hash>"`
  #     by `Pravda::AuthorBlogImportService`, so we can rebuild the public
  #     blogs.pravda.com.ua URL deterministically.
  def display_source_name
    return self[:source_name].to_s.strip.presence unless self[:source_name].nil?

    external_source.presence
  end

  def source_url
    return self[:source_url].to_s.strip.presence unless self[:source_url].nil?

    return nil if external_source.blank? || external_id.blank?

    case external_source
    when "ukr_pravda_blog"
      author_slug, hash = external_id.to_s.split("/", 2)
      return nil if author_slug.blank? || hash.blank?
      "https://blogs.pravda.com.ua/authors/#{author_slug}/#{hash}/"
    end
  end

  private

  def title_presence_for_locale
    return if title_i18n.present? && title_i18n.values.any?(&:present?)

    errors.add(:title_i18n, "must have at least one translation")
  end

  def content_presence_for_locale
    has_rendered = content_i18n.is_a?(Hash) && content_i18n.values.any?(&:present?)
    has_source   = content_source_i18n.is_a?(Hash) && content_source_i18n.values.any?(&:present?)
    return if has_rendered || has_source

    errors.add(:content_i18n, "must have at least one translation")
  end

  def update_author_posts_count
    # Could be used to track monthly post limits
    # Only increment when transitioning TO published state (not already published before)
    return unless published?

    previous_status, = saved_change_to_status
    return if previous_status == "published"

    author.increment!(:posts_this_month)
  end

  def should_rerender_content?
    return true if new_record?

    will_save_change_to_attribute?(:content_source_i18n) ||
      will_save_change_to_attribute?(:content_format)
  end

  def rerender_content_per_locale!
    sources = content_source_i18n.is_a?(Hash) ? content_source_i18n : {}
    rendered = sources.each_with_object({}) do |(locale, source), acc|
      acc[locale.to_s] = Posts::ContentRenderer.render(self, locale, source: source.to_s)
    end
    self.content_i18n = rendered if rendered.any?
  end
end
