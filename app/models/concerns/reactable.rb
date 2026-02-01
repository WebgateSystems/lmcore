# frozen_string_literal: true

module Reactable
  extend ActiveSupport::Concern

  included do
    has_many :reactions, as: :reactable, dependent: :destroy
  end

  def react!(user, reaction_type)
    reaction = reactions.find_or_initialize_by(user: user)
    reaction.reaction_type = reaction_type
    reaction.save!
    update_reactions_count
    reaction
  end

  def unreact!(user)
    reactions.find_by(user: user)&.destroy
    update_reactions_count
  end

  def reacted_by?(user, reaction_type: nil)
    scope = reactions.where(user: user)
    scope = scope.where(reaction_type: reaction_type) if reaction_type
    scope.exists?
  end

  def reactions_summary
    reactions.group(:reaction_type).count
  end

  private

  def update_reactions_count
    update_column(:reactions_count, reactions.count) if respond_to?(:reactions_count)
  end
end
