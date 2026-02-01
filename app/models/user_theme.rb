# frozen_string_literal: true

class UserTheme < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :theme

  # Validations
  validates :user_id, uniqueness: { scope: :theme_id }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :purchased, -> { where.not(purchased_at: nil) }

  # Callbacks
  before_save :deactivate_other_themes, if: :active_changed_to_true?

  # Instance methods
  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  def purchased?
    purchased_at.present?
  end

  def purchase!
    update!(purchased_at: Time.current) unless purchased?
  end

  def customization(key)
    customizations[key.to_s]
  end

  def set_customization(key, value)
    self.customizations = customizations.merge(key.to_s => value)
  end

  def reset_customizations!
    update!(customizations: {})
  end

  private

  def active_changed_to_true?
    active_changed? && active?
  end

  def deactivate_other_themes
    user.user_themes.where.not(id: id).update_all(active: false)
  end
end
