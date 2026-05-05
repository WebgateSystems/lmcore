# frozen_string_literal: true

class SiteSetting < ApplicationRecord
  SOCIAL_LINK_PLATFORMS = [
    { "key" => "facebook", "label" => "Facebook" },
    { "key" => "twitter", "label" => "X / Twitter" },
    { "key" => "instagram", "label" => "Instagram" },
    { "key" => "youtube", "label" => "YouTube" },
    { "key" => "threads", "label" => "Threads" },
    { "key" => "bluesky", "label" => "Bluesky" },
    { "key" => "linkedin", "label" => "LinkedIn" },
    { "key" => "github", "label" => "GitHub" }
  ].freeze

  LEGACY_SOCIAL_LINK_KEYS = {
    "facebook" => "social_facebook",
    "twitter" => "social_twitter",
    "instagram" => "social_instagram",
    "youtube" => "social_youtube"
  }.freeze

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

    # Locales this blog owner exposes (dashboard, profile /edit, blog theme switcher).
    # Stored value may use "ua" for Ukrainian; canonical is always "uk". Sorted alphabetically.
    # If unset or empty, defaults to %w[en] only — never the full platform list.
    def blog_available_locale_codes_for(user)
      parse_blog_available_locales(get("available_locales", user: user, default: nil))
    end

    def normalize_social_links(raw)
      rows = case raw
      when Array then raw
      when Hash then raw.values
      else []
      end
      allowed = SOCIAL_LINK_PLATFORMS.to_h { |platform| [ platform["key"], platform["label"] ] }

      rows.filter_map do |row|
        attrs = row.respond_to?(:to_h) ? row.to_h : {}
        platform = attrs["platform"].to_s.presence || attrs[:platform].to_s
        url = attrs["url"].to_s.presence || attrs[:url].to_s
        platform = platform.strip.downcase
        url = url.strip
        next if platform.blank? || url.blank? || !allowed.key?(platform)

        { "platform" => platform, "label" => allowed[platform], "url" => url }
      end
    end

    def social_links_from_settings_hash(settings_hash)
      configured = normalize_social_links(settings_hash["social_links"])
      return configured if configured.any? || settings_hash.key?("social_links")

      legacy_rows = LEGACY_SOCIAL_LINK_KEYS.filter_map do |platform, setting_key|
        url = settings_hash[setting_key].to_s.strip
        url = settings_hash["youtube_url"].to_s.strip if platform == "youtube" && url.blank?
        next if url.blank?

        { "platform" => platform, "url" => url }
      end
      normalize_social_links(legacy_rows)
    end

    # Public helper: turn anything (Array, comma string, JSON-array string) into a
    # canonicalised, platform-filtered, sorted Array<String> of locale codes.
    # If the input is empty or unparseable, falls back to %w[en].
    def parse_blog_available_locales(raw)
      list = case raw
      when Array then raw.map(&:to_s)
      when String then split_locale_string(raw)
      else []
      end
      list = list.map { |l| l.to_s.strip.downcase == "ua" ? "uk" : l.to_s.strip.downcase }
      list = list.reject(&:blank?)
      platform = I18n.available_locales.map(&:to_s)
      list = list.select { |l| platform.include?(l) }
      list.uniq!
      list.sort!
      list.presence || %w[en]
    end

    private

    # Tolerate strings produced by older code that serialized arrays via
    # `Array#to_s` (e.g. `"[\"en\", \"pl\"]"`). Strip JSON-array syntax and
    # quotes so that legacy values still parse to a useful locale list.
    def split_locale_string(raw)
      cleaned = raw.to_s.tr('[]"', "").gsub(/\s+/, "")
      cleaned.split(",").map(&:strip)
    end

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
