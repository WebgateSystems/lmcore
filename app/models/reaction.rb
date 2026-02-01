# frozen_string_literal: true

class Reaction < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :reactable, polymorphic: true

  # Validations
  validates :reaction_type, presence: true, inclusion: { in: %w[like love haha wow sad angry] }
  validates :user_id, uniqueness: { scope: %i[reactable_type reactable_id] }

  # Scopes
  scope :likes, -> { where(reaction_type: "like") }
  scope :loves, -> { where(reaction_type: "love") }
  scope :by_type, ->(type) { where(reaction_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :update_reactable_count
  after_destroy :update_reactable_count

  # Constants
  TYPES = %w[like love haha wow sad angry].freeze

  # Instance methods
  TYPES.each do |type|
    define_method("#{type}?") do
      reaction_type == type
    end
  end

  private

  def update_reactable_count
    reactable.update_column(:reactions_count, reactable.reactions.count) if reactable.respond_to?(:reactions_count)
  end
end
