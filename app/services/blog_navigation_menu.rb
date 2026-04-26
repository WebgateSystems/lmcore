# frozen_string_literal: true

class BlogNavigationMenu
  STATIC_ITEMS = [
    { id: "home", key: "home" },
    { id: "about", key: "about" },
    { id: "videos", key: "videos" },
    { id: "posts", key: "articles" },
    { id: "gallery", key: "gallery" }
  ].freeze

  SETTING_KEY = "navigation_menu"

  def initialize(user:)
    @user = user
  end

  def items
    base = default_items
    config = settings_by_id

    base.each_with_index do |item, index|
      configured = config[item[:id]] || {}
      item[:visible] = configured.key?("visible") ? configured["visible"] : true
      item[:position] = configured["position"].to_i.positive? ? configured["position"].to_i : index + 1
    end

    base.sort_by { |item| [ item[:position], item[:default_position] ] }
  end

  def save!(order_ids:, visibility_by_id:)
    normalized_ids = Array(order_ids).map(&:to_s).uniq
    current_ids = items.map { |item| item[:id] }
    raise ArgumentError, "Invalid menu order payload" unless normalized_ids.sort == current_ids.sort

    payload = normalized_ids.each_with_index.map do |id, idx|
      visible = ActiveModel::Type::Boolean.new.cast(visibility_by_id[id])
      { "id" => id, "position" => idx + 1, "visible" => visible }
    end

    setting = SiteSetting.find_or_initialize_by(user: @user, key: SETTING_KEY)
    setting.value = { "data" => payload }
    setting.value_type = "json"
    setting.category ||= "general"
    setting.save!
  end

  private

  def default_items
    static_items = STATIC_ITEMS.each_with_index.map do |item, idx|
      {
        id: item[:id],
        kind: "static",
        navigation_key: item[:key],
        slug: static_slug_for(item[:id]),
        page: nil,
        default_position: idx + 1
      }
    end

    pages = @user.pages.published.in_menu.to_a
    page_items = pages.each_with_index.map do |page, idx|
      {
        id: "page:#{page.id}",
        kind: "page",
        navigation_key: nil,
        slug: page.slug,
        page: page,
        default_position: static_items.size + idx + 1
      }
    end

    static_items + page_items
  end

  def static_slug_for(static_id)
    return nil if static_id == "home"

    case static_id
    when "about" then "about"
    when "videos" then "videos"
    when "posts" then "posts"
    when "gallery" then "gallery"
    end
  end

  def settings_by_id
    raw = SiteSetting.get(SETTING_KEY, user: @user, default: nil)
    entries = raw.is_a?(Array) ? raw : []

    entries.each_with_object({}) do |entry, memo|
      next unless entry.is_a?(Hash)

      id = entry["id"].to_s
      next if id.blank?

      memo[id] = {
        "position" => entry["position"],
        "visible" => entry["visible"]
      }
    end
  end
end
