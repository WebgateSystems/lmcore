# frozen_string_literal: true

class ThemeAccess < ApplicationRecord
  belongs_to :theme
  belongs_to :user

  validates :user_id, uniqueness: { scope: :theme_id }
end
