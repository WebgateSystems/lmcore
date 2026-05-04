# frozen_string_literal: true

require "liquid"

class ThemeRenderer
  class TemplateNotFound < StandardError; end
  class LayoutNotFound < StandardError; end

  def initialize(theme_slug)
    @theme_path = Rails.root.join("themes", theme_slug)
    @file_system = ThemeFileSystem.new(@theme_path)
    self.class.load_theme_translations!(@theme_path)
    @environment = build_environment(theme_slug)
  end

  def render(template_name, assigns = {}, layout: "application")
    template_content = read_file(template_name)
    content = render_liquid(template_content, assigns)

    if layout
      layout_content = read_file("layouts/#{layout}")
      render_liquid(layout_content, assigns.merge("content" => content))
    else
      content
    end
  end

  def template_exists?(name)
    @theme_path.join("#{name}.liquid").exist?
  end

  private

  THEME_LOCALE_GLOB = "locales/**/*.{rb,yml}"

  class << self
    def load_theme_translations!(theme_path)
      files = Dir[theme_path.join(THEME_LOCALE_GLOB)].sort
      signature = files.to_h { |path| [ path, File.mtime(path).to_f ] }

      theme_locale_mutex.synchronize do
        prune_stale_theme_locale_load_paths!
        return if files.empty?
        return if loaded_theme_locale_signatures[theme_path.to_s] == signature

        I18n.backend.load_translations(*files)
        loaded_theme_locale_signatures[theme_path.to_s] = signature
      end
    end

    private

    def theme_locale_mutex
      @theme_locale_mutex ||= Mutex.new
    end

    def loaded_theme_locale_signatures
      @loaded_theme_locale_signatures ||= {}
    end

    def prune_stale_theme_locale_load_paths!
      themes_root = Rails.root.join("themes").to_s
      stale_paths = I18n.load_path.select do |path|
        path = path.to_s
        path.start_with?(themes_root) && !File.exist?(path)
      end
      return if stale_paths.empty?

      I18n.load_path -= stale_paths
    end
  end

  def build_environment(theme_slug)
    Liquid::Environment.build do |env|
      env.file_system = @file_system
      env.error_mode = Rails.env.development? ? :warn : :strict
      env.register_filter(BlogFilters)
      env.register_filter(UrlFilters)
      env.register_filter(DateFilters)
      env.register_filter(AssetFilters)
      env.register_filter(I18nFilters)
    end
  end

  def render_liquid(content, assigns)
    template = Liquid::Template.parse(content, environment: @environment)
    template.render(stringify_keys(assigns))
  rescue Liquid::Error => e
    if Rails.env.development?
      "<div class='liquid-error' style='color:red;padding:1rem'>Liquid Error: #{ERB::Util.html_escape(e.message)}</div>"
    else
      Rails.logger.error("Liquid rendering error: #{e.message}")
      ""
    end
  end

  def read_file(name)
    path = @theme_path.join("#{name}.liquid")
    raise TemplateNotFound, "Template not found: #{name} at #{path}" unless path.exist?

    path.read
  end

  def stringify_keys(hash)
    hash.each_with_object({}) do |(k, v), result|
      result[k.to_s] = convert_value(v)
    end
  end

  def convert_value(value)
    case value
    when Hash then stringify_keys(value)
    when Array then value.map { |v| convert_value(v) }
    when ActiveRecord::Base then model_to_hash(value)
    else value
    end
  end

  def model_to_hash(record)
    record.attributes.transform_values { |v| convert_value(v) }
  end

  # Resolves {% include 'partial_name' %} from the theme's partials directory
  class ThemeFileSystem
    def initialize(theme_path)
      @theme_path = theme_path
    end

    def read_template_file(template_path)
      full_path = @theme_path.join("partials", "#{template_path}.liquid")
      raise Liquid::FileSystemError, "Partial not found: #{template_path}" unless full_path.exist?

      full_path.read
    end
  end

  module BlogFilters
    def truncate_words(input, words = 20, truncate_string = "...")
      return "" if input.nil?

      wordlist = input.to_s.split
      return input if wordlist.length <= words

      wordlist[0...words].join(" ") + truncate_string
    end

    def strip_html(input)
      input.to_s
        .gsub(%r{<br\s*/?>}i, " ")
        .gsub(%r{</?(div|p|h[1-6]|li|tr|td|th|blockquote|span)[^>]*>}i, " ")
        .gsub(/<[^>]*>/, "")
        .gsub(/\s+/, " ")
        .strip
    end

    def reading_time(input, words_per_minute = 200)
      return "1 min" if input.nil?

      words = strip_html(input).split.length
      minutes = (words.to_f / words_per_minute).ceil
      "#{minutes} min"
    end

    def excerpt(input, length = 200)
      text = strip_html(input.to_s)
      return text if text.length <= length

      "#{text[0...length].gsub(/\s+\S*$/, "")}..."
    end
  end

  module UrlFilters
    def post_url(slug)
      base = @context["base_path"].to_s
      "#{base}/posts/#{slug}"
    end

    def video_url(slug)
      base = @context["base_path"].to_s
      "#{base}/videos/#{slug}"
    end

    def photo_url(slug)
      base = @context["base_path"].to_s
      "#{base}/gallery/#{slug}"
    end

    def gallery_url(slug)
      base = @context["base_path"].to_s
      "#{base}/gallery/#{slug}"
    end

    def tag_url(slug)
      base = @context["base_path"].to_s
      "#{base}/tags/#{slug}"
    end

    def category_url(slug)
      base = @context["base_path"].to_s
      "#{base}/categories/#{slug}"
    end

    def page_url(slug)
      base = @context["base_path"].to_s
      "#{base}/pages/#{slug}"
    end

    def search_url
      base = @context["base_path"].to_s
      "#{base}/search"
    end
  end

  module DateFilters
    def date_format(input, format = "%d.%m.%Y")
      return "" if input.nil?

      case input
      when Time, DateTime, Date then input.strftime(format)
      when String then Time.parse(input).strftime(format)
      else input.to_s
      end
    rescue ArgumentError
      input.to_s
    end

    def time_ago(input)
      return "" if input.nil?

      time = input.is_a?(Time) ? input : Time.parse(input.to_s)
      seconds = (Time.now - time).to_i

      case seconds
      when 0..59 then "just now"
      when 60..3599 then "#{seconds / 60} minutes ago"
      when 3600..86_399 then "#{seconds / 3600} hours ago"
      when 86_400..604_799 then "#{seconds / 86_400} days ago"
      else date_format(input)
      end
    rescue ArgumentError
      input.to_s
    end
  end

  module AssetFilters
    def theme_asset(path)
      slug = @context["theme_slug"] || "default"
      "/themes/#{slug}/#{path}"
    end

    def stylesheet_tag(path)
      %(<link rel="stylesheet" href="#{theme_asset(path)}">)
    end

    def javascript_tag(path)
      %(<script src="#{theme_asset(path)}"></script>)
    end
  end

  module I18nFilters
    def t(key)
      scope = @context["theme_translation_scope"].to_s
      scoped_key = scope.present? ? "#{scope}.#{key}" : key
      result = I18n.t(scoped_key, default: nil)
      result || I18n.t(key, default: key.to_s)
    rescue StandardError
      key.to_s
    end

    def localize(input, format = :default)
      return "" if input.nil?
      I18n.l(input, format: format.to_sym)
    rescue I18n::MissingTranslationData, ArgumentError
      input.to_s
    end
  end
end
