# frozen_string_literal: true

require "tempfile"
require "fileutils"
require "uri"

module Pravda
  # Imports every article from a blogs.pravda.com.ua author blog into the
  # Posts table, owned by `user`. Idempotent on repeat runs (matched by
  # `external_source` + `external_id`).
  class AuthorBlogImportService
    EXTERNAL_SOURCE = "ukr_pravda_blog"

    Stats = Struct.new(:total, :created, :updated, :skipped, :errors, keyword_init: true) do
      def to_h
        super
      end
    end

    attr_reader :user, :author_slug, :http, :scraper, :locale,
                :category_slug, :max_articles, :download_images,
                :progress, :logger

    def initialize(user:,
                   author_slug:,
                   locale: "uk",
                   category_slug: nil,
                   max_articles: nil,
                   download_images: true,
                   http: Pravda::HttpClient.new,
                   scraper: nil,
                   progress: nil,
                   logger: Rails.logger)
      @user = user
      @author_slug = author_slug.to_s.tr("/", "")
      @locale = locale.to_s
      @category_slug = category_slug
      @max_articles = max_articles&.to_i
      @download_images = download_images
      @http = http
      @scraper = scraper || Pravda::BlogIndexScraper.new(author_slug: @author_slug, http: @http)
      @progress = progress
      @logger = logger
    end

    def call
      stats = Stats.new(total: 0, created: 0, updated: 0, skipped: 0, errors: 0)

      emit(:start, user_id: user.id, author_slug: author_slug, locale: locale)

      emit(:phase, name: "discover_articles")
      urls = scraper.article_urls
      urls = urls.first(max_articles) if max_articles
      stats.total = urls.size
      emit(:discovered, total: stats.total)

      urls.each_with_index do |article_url, index|
        external_id = "#{author_slug}/" + article_url.match(%r{/([0-9a-f]{6,})/?\z})[1]
        emit(:progress_start, index: index + 1, total: stats.total, url: article_url, external_id: external_id)

        begin
          html = http.get_html(article_url)
          parsed = Pravda::ArticleParser.new(html: html, url: article_url).call

          if parsed[:title].blank? || parsed[:content_html].blank?
            stats.skipped += 1
            emit(:skip, index: index + 1, url: article_url, reason: "empty_post", stats: stats.to_h)
            next
          end

          result = upsert_post!(parsed)
          case result
          when :created then stats.created += 1
          when :updated then stats.updated += 1
          when :skipped then stats.skipped += 1
          end

          emit(:progress, index: index + 1, total: stats.total, url: article_url,
                          external_id: external_id, result: result, stats: stats.to_h)
        rescue StandardError => e
          stats.errors += 1
          logger&.error("[Pravda] error importing #{article_url}: #{e.class}: #{e.message}")
          logger&.error(e.backtrace&.first(5)&.join("\n"))
          emit(:error, index: index + 1, url: article_url, message: e.message, stats: stats.to_h)
        end
      end

      emit(:finish, stats: stats.to_h)
      stats.to_h
    end

    # ------------------------------------------------------------------
    # Persistence
    # ------------------------------------------------------------------

    def upsert_post!(parsed)
      temp_files = []
      post = user.posts.with_discarded.find_or_initialize_by(
        external_source: EXTERNAL_SOURCE,
        external_id: parsed[:external_id]
      )

      action = post.new_record? ? :created : :updated

      post.assign_attributes(
        status: "published",
        content_format: "html",
        published_at: parsed[:published_at] || Time.current,
        external_date: parsed[:published_at],
        category: resolve_category(parsed[:category_name_uk]),
        views_count: parsed[:views_count].to_i
      )
      post.title_i18n = (post.title_i18n || {}).merge(locale => parsed[:title])
      post.lead_i18n  = (post.lead_i18n  || {}).merge(locale => parsed[:lead].to_s) if parsed[:lead].present?

      attachments_by_url = build_attachments_for(post, parsed[:images])
      content_source = bind_attachments_into_html(parsed[:content_html], attachments_by_url)
      content_source = append_orphan_youtube_embeds(content_source, parsed[:youtube_video_ids])
      post.content_source_i18n = (post.content_source_i18n || {}).merge(locale => content_source)

      if download_images && parsed[:featured_image_url].present? && post.featured_image.blank?
        attach_featured_image!(post, parsed[:featured_image_url], temp_files)
      end

      # Sluggable reads `title` with `I18n.locale` (often :en during rake). Import
      # stores title only under `locale` (e.g. "uk"), and Cyrillic `parameterize`
      # can yield "" — then validation fails. Set slug explicitly before save.
      assign_import_slug!(post, parsed) if post.slug.blank?

      post.save!
      action
    ensure
      temp_files&.each do |tf|
        begin
          tf.close
          tf.unlink
        rescue StandardError
          nil
        end
      end
    end

    private

    def assign_import_slug!(post, parsed)
      post.author_id ||= user.id

      base = slug_base_from_import(parsed)
      post.slug = unique_slug_for_author(post, base)
    end

    # ASCII slug matching Post validation /\A[a-z0-9\-]+\z/
    def slug_base_from_import(parsed)
      title = parsed[:title].to_s
      loc = locale.to_sym

      base = title.parameterize(locale: loc)
      base = title.parameterize(locale: :uk) if base.blank? && loc != :uk
      base = title.parameterize(locale: :ru) if base.blank?
      base = title.parameterize if base.blank?

      if base.blank?
        ext = parsed[:external_id].to_s.downcase
        ext = ext.gsub(%r{[^a-z0-9]+}, "-").squeeze("-").gsub(/\A-|-\z/, "")
        base = ext.presence || "pravda"
      end

      base = base.downcase.gsub(/[^a-z0-9\-]+/, "-").squeeze("-").gsub(/\A-|-\z/, "")
      base = "pravda" if base.blank?
      base
    end

    def unique_slug_for_author(post, base)
      scope = Post.with_discarded.where(author_id: post.author_id)
      scope = scope.where.not(id: post.id) if post.persisted?

      slug = base
      counter = 1
      while scope.exists?(slug: slug)
        slug = "#{base}-#{counter}"
        counter += 1
      end
      slug
    end

    def emit(event, payload = {})
      progress&.call(event, payload)
    rescue StandardError => e
      logger&.warn("[Pravda] progress callback raised: #{e.class}: #{e.message}")
    end

    def resolve_category(name_uk)
      return @resolved_category if defined?(@resolved_category) && @resolved_category && category_slug.blank? && name_uk.blank?

      if category_slug.present?
        return @explicit_category ||= Category.find_by(slug: category_slug)
      end

      return nil if name_uk.blank?

      Category.where("name_i18n ->> 'uk' = ?", name_uk).first ||
        Category.where("name_i18n ->> 'uk' ILIKE ?", name_uk).first ||
        Category.find_by(slug: "politics")
    end

    def build_attachments_for(post, images)
      return {} unless download_images && images.any?

      mapping = {}
      images.each do |img|
        url = img[:src]
        next if url.blank?

        attachment = post.media_attachments.where(attachment_type: "image")
                         .where("file_data ->> 'source_url' = ?", url).first ||
                     create_attachment_from_url!(post, url, img)
        mapping[url] = attachment if attachment
      end
      mapping
    rescue StandardError => e
      logger&.warn("[Pravda] failed to fetch images for post #{post.external_id}: #{e.message}")
      {}
    end

    def create_attachment_from_url!(post, url, img_meta)
      data = http.get_binary(url)
      return nil if data.blank?

      filename = File.basename(URI(url).path.presence || "image")
      filename = "image.jpg" if filename.blank? || !filename.include?(".")

      Tempfile.create([ "pravda-img-", File.extname(filename) ], binmode: true) do |tmp|
        tmp.write(data)
        tmp.rewind

        uploaded = Rack::Test::UploadedFile.new(tmp.path, mime_for(filename), true, original_filename: filename)
        attachment = post.media_attachments.new(
          user: user,
          attachment_type: "image",
          file: uploaded,
          file_data: { "source_url" => url }
        )
        attachment.alt_text_i18n = { locale => img_meta[:alt].to_s } if img_meta[:alt].present?
        attachment.caption_i18n = { locale => img_meta[:caption].to_s } if img_meta[:caption].present?
        attachment.save!
        attachment
      end
    rescue StandardError => e
      logger&.warn("[Pravda] image fetch failed for #{url}: #{e.message}")
      nil
    end

    def attach_featured_image!(post, url, temp_files)
      data = http.get_binary(url)
      return if data.blank?

      filename = File.basename(URI(url).path.presence || "featured.jpg")
      filename = "featured.jpg" if filename.blank? || !filename.include?(".")

      tempfile = Tempfile.new([ "pravda-feat-", File.extname(filename).presence || ".jpg" ])
      tempfile.binmode
      tempfile.write(data)
      tempfile.rewind
      temp_files << tempfile

      post.featured_image = Rack::Test::UploadedFile.new(tempfile.path, mime_for(filename), true, original_filename: filename)
    rescue StandardError => e
      logger&.warn("[Pravda] featured image fetch failed for #{url}: #{e.message}")
    end

    # Replaces `<figure data-image-url="...">` placeholders emitted by the
    # parser with `<figure data-attachment-id="UUID">` so the
    # `Posts::ContentRenderer` pipeline can substitute the persisted media
    # URL on render.
    def bind_attachments_into_html(html, attachments_by_url)
      return html if html.blank?

      doc = Nokogiri::HTML5.fragment(html)
      doc.css("figure[data-image-url]").each do |fig|
        url = fig["data-image-url"]
        attachment = attachments_by_url[url]
        if attachment
          fig["data-attachment-id"] = attachment.id
          fig.remove_attribute("data-image-url")
          fig.remove_attribute("data-image-alt")
          fig.children.unlink
        end
      end
      doc.to_html
    end

    # Appends `<figure class="embed-youtube">` blocks for any YouTube IDs the
    # parser discovered in the source page that did not already make it into
    # the rewritten content (e.g. when the original markup was a JS-rendered
    # player widget instead of a real <iframe>/standalone link).
    def append_orphan_youtube_embeds(html, video_ids)
      return html if video_ids.blank?

      already_present = html.to_s.scan(/data-video-id="([^"]+)"/).flatten
      missing = Array(video_ids) - already_present
      return html if missing.empty?

      blocks = missing.map { |id| youtube_embed_html(id) }.join("\n")
      "#{html}\n#{blocks}"
    end

    # Marker only — `Posts::ContentRenderer#expand_inline_video_embeds`
    # rewrites this into a "Powiązane wideo" link to YouTube on render.
    def youtube_embed_html(video_id)
      escaped = ERB::Util.html_escape(video_id.to_s)
      %(<figure class="embed-youtube" data-video-id="#{escaped}"></figure>)
    end

    def mime_for(filename)
      case File.extname(filename).downcase
      when ".png"  then "image/png"
      when ".gif"  then "image/gif"
      when ".webp" then "image/webp"
      when ".jpg", ".jpeg" then "image/jpeg"
      else "image/jpeg"
      end
    end
  end
end
