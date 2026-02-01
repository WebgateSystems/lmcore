# frozen_string_literal: true

class Category < ApplicationRecord
  include Sluggable
  include Translatable

  # Translations
  translates :name, :description

  # Slug configuration
  sluggable_source :name
  slug_scope :user_id

  # Associations
  belongs_to :user
  belongs_to :parent, class_name: "Category", optional: true, counter_cache: false
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :nullify, inverse_of: :parent
  has_many :posts, dependent: :nullify
  has_many :videos, dependent: :nullify
  has_many :photos, dependent: :nullify

  # CarrierWave
  mount_uploader :cover_image, ImageUploader

  # Validations
  validates :slug, presence: true, uniqueness: { scope: :user_id }
  validates :category_type, presence: true, inclusion: { in: %w[general posts videos photos] }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :parent_cannot_be_self
  validate :parent_must_belong_to_same_user

  # Scopes
  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(position: :asc) }
  scope :for_posts, -> { where(category_type: %w[general posts]) }
  scope :for_videos, -> { where(category_type: %w[general videos]) }
  scope :for_photos, -> { where(category_type: %w[general photos]) }

  # Instance methods
  def root?
    parent_id.nil?
  end

  def leaf?
    children.empty?
  end

  def ancestors
    ancestors_list = []
    current = parent
    while current
      ancestors_list.unshift(current)
      current = current.parent
    end
    ancestors_list
  end

  def descendants
    children.flat_map { |child| [ child ] + child.descendants }
  end

  def depth
    ancestors.length
  end

  def content_count
    posts_count + videos_count + photos_count
  end

  private

  def parent_cannot_be_self
    errors.add(:parent_id, "can't be self") if id.present? && parent_id == id
  end

  def parent_must_belong_to_same_user
    return unless parent.present? && parent.user_id != user_id

    errors.add(:parent_id, "must belong to the same user")
  end
end
