# frozen_string_literal: true

class Tag < ApplicationRecord
  include Sluggable

  # Slug configuration
  sluggable_source :name

  # Associations
  has_many :taggings, dependent: :destroy
  has_many :posts, through: :taggings, source: :taggable, source_type: "Post"
  has_many :videos, through: :taggings, source: :taggable, source_type: "Video"
  has_many :photos, through: :taggings, source: :taggable, source_type: "Photo"

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :popular, -> { order(taggings_count: :desc) }
  scope :alphabetical, -> { order(name: :asc) }
  scope :with_content, -> { where("taggings_count > 0") }

  # Callbacks
  before_validation :normalize_name

  # Class methods
  class << self
    def find_or_create_by_name(name)
      find_or_create_by!(name: name.strip.downcase) do |tag|
        tag.slug = name.strip.parameterize
      end
    end

    def popular_tags(limit: 20)
      popular.limit(limit)
    end

    def search(query)
      where("name ILIKE ?", "%#{query}%")
    end
  end

  # Instance methods
  def merge_into(other_tag)
    return false if other_tag == self

    taggings.update_all(tag_id: other_tag.id)
    other_tag.update_column(:taggings_count, other_tag.taggings.count)
    destroy
  end

  private

  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end
