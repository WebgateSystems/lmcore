# frozen_string_literal: true

class Tagging < ApplicationRecord
  # Associations
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true

  # Validations
  validates :tag_id, uniqueness: { scope: %i[taggable_type taggable_id] }

  # Disable auditing for this join model
  auditable enabled: false
end
