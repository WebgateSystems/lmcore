# frozen_string_literal: true

class SiteSetting < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Validations
  validates :key, presence: true, uniqueness: { scope: :user_id }
  validates :value_type, presence: true, inclusion: { in: %w[string integer boolean json text] }

  # Scopes
  scope :global, -> { where(user_id: nil) }
  scope :for_user, ->(user) { where(user: user) }
  scope :by_category, ->(category) { where(category: category) }

  # Class methods
  class << self
    def get(key, user: nil, default: nil)
      setting = find_by(key: key, user: user) || find_by(key: key, user_id: nil)
      setting ? setting.typed_value : default
    end

    def set(key, value, user: nil, category: "general", value_type: nil)
      setting = find_or_initialize_by(key: key, user: user)
      setting.value = { "data" => value }
      setting.category = category
      setting.value_type = value_type || infer_value_type(value)
      setting.save!
      setting
    end

    def categories
      distinct.pluck(:category).compact.sort
    end

    private

    def infer_value_type(value)
      case value
      when TrueClass, FalseClass then "boolean"
      when Integer then "integer"
      when Hash, Array then "json"
      else "string"
      end
    end
  end

  # Instance methods
  def typed_value
    raw_value = value["data"]
    return raw_value if raw_value.nil?

    case value_type
    when "integer" then raw_value.to_i
    when "boolean" then raw_value.to_s == "true"
    when "json" then raw_value
    when "text", "string" then raw_value.to_s
    else raw_value
    end
  end

  def global?
    user_id.nil?
  end

  def user_specific?
    user_id.present?
  end
end
