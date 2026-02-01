# frozen_string_literal: true

class Post < ApplicationRecord
  include Discard::Model
  include Sluggable
  include Publishable
  include Translatable
  include Taggable
  include Commentable
  include Reactable

  # Translations
  translates :title, :subtitle, :lead, :content, :keywords, :meta_description

  # Slug configuration
  sluggable_source :title
  slug_scope :author_id

  # Associations
  belongs_to :author, class_name: "User", inverse_of: :posts
  belongs_to :category, optional: true, counter_cache: true
  belongs_to :published_by, class_name: "User", optional: true
  has_many :media_attachments, as: :attachable, dependent: :destroy
  has_many :content_visibilities, as: :visible, dependent: :destroy

  # CarrierWave
  mount_uploader :featured_image, ImageUploader
  mount_uploader :og_image, ImageUploader

  # Validations
  validates :slug, presence: true, uniqueness: { scope: :author_id }
  validates :status, presence: true, inclusion: { in: %w[draft pending scheduled published archived] }
  validate :title_presence_for_locale
  validate :content_presence_for_locale

  # Scopes
  scope :by_author, ->(author) { where(author: author) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :popular, -> { order(views_count: :desc) }
  scope :for_feed, -> { published.visible.includes(:author, :category, :tags).recent }

  # Callbacks
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

  private

  def title_presence_for_locale
    return if title_i18n.present? && title_i18n.values.any?(&:present?)

    errors.add(:title_i18n, "must have at least one translation")
  end

  def content_presence_for_locale
    return if content_i18n.present? && content_i18n.values.any?(&:present?)

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
end
