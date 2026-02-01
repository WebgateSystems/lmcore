# frozen_string_literal: true

module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: :should_generate_slug?
    validates :slug, presence: true, format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  end

  class_methods do
    def sluggable_source(attribute = :name)
      @sluggable_source = attribute
    end

    def get_sluggable_source
      @sluggable_source || :name
    end

    def slug_scope(*scopes)
      @slug_scope = scopes
    end

    def get_slug_scope
      @slug_scope || []
    end
  end

  private

  def should_generate_slug?
    slug.blank? && respond_to?(self.class.get_sluggable_source)
  end

  def generate_slug
    source_value = send(self.class.get_sluggable_source)
    return if source_value.blank?

    base_slug = source_value.to_s.parameterize
    self.slug = unique_slug(base_slug)
  end

  def unique_slug(base_slug)
    slug = base_slug
    counter = 1
    scope = build_slug_scope

    while scope.exists?(slug: slug)
      slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    slug
  end

  def build_slug_scope
    scope = self.class.where.not(id: id)
    self.class.get_slug_scope.each do |scope_attr|
      scope = scope.where(scope_attr => send(scope_attr))
    end
    scope
  end
end
