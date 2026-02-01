# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings
  end

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    tag_names = names.is_a?(Array) ? names : names.to_s.split(",").map(&:strip)
    self.tags = tag_names.uniq.map do |name|
      Tag.find_or_create_by!(name: name) do |tag|
        tag.slug = name.parameterize
      end
    end
  end

  def add_tag(name)
    tag = Tag.find_or_create_by!(name: name.strip) do |t|
      t.slug = name.strip.parameterize
    end
    tags << tag unless tags.include?(tag)
    tag
  end

  def remove_tag(name)
    tag = tags.find_by(name: name.strip)
    tags.delete(tag) if tag
  end

  def has_tag?(name)
    tags.exists?(name: name.strip)
  end
end
