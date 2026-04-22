# frozen_string_literal: true

class Album < ApplicationRecord
  include Discard::Model
  include Sluggable
  include Publishable
  include Translatable
  include TitleSearchable
  include Taggable
  include Commentable
  include Reactable

  translates :title, :description, :keywords

  sluggable_source :title
  slug_scope :author_id

  belongs_to :author, class_name: "User", inverse_of: :albums
  belongs_to :category, optional: true
  belongs_to :published_by, class_name: "User", optional: true
  belongs_to :cover_photo, class_name: "Photo", optional: true
  has_many :photos, -> { order(position: :asc, created_at: :asc) }, dependent: :destroy, inverse_of: :album
  has_many :media_attachments, as: :attachable, dependent: :destroy
  has_many :content_visibilities, as: :visible, dependent: :destroy

  validates :slug, presence: true, uniqueness: { scope: :author_id }
  validates :status, presence: true, inclusion: { in: %w[draft pending scheduled published archived] }

  scope :by_author, ->(author) { where(author: author) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :for_gallery, -> { published.visible.recent }

  def increment_views!
    increment!(:views_count)
  end

  def display_cover
    cover_photo || photos.first
  end

  def cover_photo_url
    display_cover&.image&.url
  end
end
