# frozen_string_literal: true

require "nokogiri"
require "uri"

module Pravda
  # Parses a single article page on blogs.pravda.com.ua into a structured
  # hash that the import service can persist as a `Post`.
  #
  # The parser intentionally does NOT touch the network; it operates on a
  # raw HTML string. Image binaries are downloaded later by the import
  # service so this class stays trivially testable.
  class ArticleParser
    UA_MONTHS = {
      "січня" => 1, "лютого" => 2, "березня" => 3, "квітня" => 4,
      "травня" => 5, "червня" => 6, "липня" => 7, "серпня" => 8,
      "вересня" => 9, "жовтня" => 10, "листопада" => 11, "грудня" => 12
    }.freeze

    YOUTUBE_HOSTS = %w[
      www.youtube.com youtube.com youtu.be
      www.youtube-nocookie.com youtube-nocookie.com m.youtube.com
    ].freeze

    VIMEO_HOSTS = %w[player.vimeo.com vimeo.com].freeze

    DISCLAIMER_SELECTOR = "p.hl3"

    attr_reader :html, :url, :doc

    def initialize(html:, url: nil)
      @html = html.to_s
      @url = url
      @doc = Nokogiri::HTML5.parse(@html)
    end

    # Returns a hash:
    #   {
    #     external_id:  "muzhdabaev/69da50522c55e",
    #     canonical_url: "https://blogs.pravda.com.ua/authors/muzhdabaev/69da50522c55e/",
    #     title: "...", subtitle: nil, lead: "...",
    #     published_at: <Time, UTC>,
    #     views_count: 302,
    #     category_name_uk: "Політика",
    #     featured_image_url: "https://blogimg.pravda.com/...jpg",
    #     content_html: "<p>...</p><figure data-image-url=...>...</figure>",
    #     images: [{ src:, alt:, caption: }, ...],
    #     youtube_video_ids: ["ygAotYpyHUs", ...]
    #   }
    def call
      {
        external_id: extract_external_id,
        canonical_url: extract_canonical_url,
        title: extract_title,
        lead: extract_lead,
        published_at: extract_published_at,
        views_count: extract_views_count,
        category_name_uk: extract_category_name,
        featured_image_url: extract_featured_image_url,
        content_html: cleaned_content_html,
        images: extracted_images,
        youtube_video_ids: extracted_youtube_video_ids
      }
    end

    # ------------------------------------------------------------------
    # Field extractors (public so they can be unit-tested individually).
    # ------------------------------------------------------------------

    def extract_external_id
      target = url || extract_canonical_url
      return nil if target.blank?

      m = target.match(%r{/authors/([^/]+)/([0-9a-f]{6,})/?\z}i)
      m ? "#{m[1]}/#{m[2]}" : nil
    end

    def extract_canonical_url
      og = doc.at_css('meta[property="og:url"]')
      og&.[]("content").presence || url
    end

    def extract_title
      og = doc.at_css('meta[property="og:title"]')
      title = og&.[]("content").presence
      title ||= doc.at_css("h1.post_title")&.text
      title.to_s.strip
    end

    def extract_lead
      og = doc.at_css('meta[property="og:description"]')
      og&.[]("content")&.strip
    end

    def extract_published_at
      raw = doc.at_css(".post_time")&.text&.strip
      return nil if raw.blank?

      m = raw.match(/\A(\d{1,2})\s+([\p{L}\-]+)\s+(\d{4}),?\s*(\d{1,2}):(\d{2})\z/u)
      return nil unless m

      day, month_name, year, hour, minute = m.captures
      month = UA_MONTHS[month_name.downcase]
      return nil unless month

      tz = Time.find_zone("Europe/Kiev") || Time.find_zone("UTC")
      tz.local(year.to_i, month, day.to_i, hour.to_i, minute.to_i).utc
    rescue ArgumentError
      nil
    end

    def extract_views_count
      raw = doc.at_css(".post_views")&.text&.strip
      raw&.match(/\d+/)&.to_s&.to_i
    end

    def extract_category_name
      link = doc.at_css(".post_menu__item a")
      return nil unless link

      # "<a><span>Розділ:</span> Політика</a>" → `.text` is "Розділ: Політика"
      text = link.text.to_s.strip.gsub(/\s+/, " ")
      text = text.sub(/\AРозділ:\s*/i, "")
                 .sub(/\AРаздел:\s*/i, "")
                 .strip
      text.presence
    end

    def extract_featured_image_url
      doc.at_css('meta[property="og:image"]')&.[]("content")
    end

    # Returns a sanitized, normalized HTML string that:
    #   - drops the standard pravda disclaimer `<p class="hl3">`
    #   - strips inline-only attributes/styles, scripts, ads
    #   - rewrites <img> to a normalized `<figure data-image-url="...">` form
    #     so the import service can replace src with a MediaAttachment id
    #   - converts <iframe>/text links to YouTube into a stable `<figure
    #     class="embed-youtube" data-video-id="X">` block
    def cleaned_content_html
      container = doc.at_css(".post_text")
      return "" unless container

      working = container.dup
      working.css(DISCLAIMER_SELECTOR).each(&:remove)
      working.css("script, style, noscript, ins, .adsbygoogle").each(&:remove)
      working.css("[onclick], [onload], [onerror]").each do |node|
        %w[onclick onload onerror].each { |a| node.remove_attribute(a) }
      end
      working.css("[style]").each { |n| n.remove_attribute("style") }
      working.css("[data-io-article-url]").each { |n| n.remove_attribute("data-io-article-url") }

      rewrite_images!(working)
      rewrite_youtube_embeds!(working)
      drop_empty_paragraphs!(working)

      working.inner_html.to_s.strip
    end

    # Returns [{ src:, alt:, caption: }, ...] in document order.
    def extracted_images
      container = doc.at_css(".post_text") or return []
      working = container.dup
      working.css(DISCLAIMER_SELECTOR).each(&:remove)

      working.css("img").map do |img|
        src = img["src"].to_s.strip
        next if src.blank?

        {
          src: absolutize_image(src),
          alt: img["alt"].to_s.strip.presence,
          caption: nearest_caption(img)
        }
      end.compact
    end

    # Unique YouTube video IDs found anywhere in the body (iframes + text
    # links to youtube.com / youtu.be).
    def extracted_youtube_video_ids
      container = doc.at_css(".post_text") or return []
      ids = []

      container.css("iframe").each do |frame|
        id = youtube_id_from_url(frame["src"])
        ids << id if id
      end
      container.css("a").each do |link|
        id = youtube_id_from_url(link["href"])
        ids << id if id
      end

      ids.uniq
    end

    private

    def rewrite_images!(node)
      node.css("img").each do |img|
        src = img["src"].to_s.strip
        next if src.blank?

        url = absolutize_image(src)
        alt = img["alt"].to_s.strip
        caption = nearest_caption(img)

        figure = Nokogiri::HTML5.fragment(figure_for_image(url, alt, caption)).children.first
        target = ancestor_figure(img) || img.parent

        # Unwrap pravda-style `<div><img></div>` so we don't leave a redundant
        # block-level wrapper around the figure.
        if target&.name == "div" && target["class"].to_s.strip.empty?
          significant = target.children.reject { |c| c.text? && c.text.strip.empty? }
          if significant == [ img ]
            target.replace(figure)
            next
          end
        end

        if target&.name == "figure" || target&.name == "p"
          target.replace(figure)
        else
          img.replace(figure)
        end
      end
    end

    def rewrite_youtube_embeds!(node)
      node.css("iframe").each do |frame|
        id = youtube_id_from_url(frame["src"])
        if id
          frame.replace(Nokogiri::HTML5.fragment(youtube_embed_html(id)))
        else
          frame.remove
        end
      end

      node.css("a").each do |link|
        id = youtube_id_from_url(link["href"])
        next unless id
        next if link.text.to_s.strip.empty?

        # Only convert standalone link paragraphs; keep inline anchor links
        # as anchors that point to YouTube.
        parent = link.parent
        is_standalone = parent && parent.name == "p" && parent.children.reject { |c| c.text? && c.text.strip.empty? } == [ link ]
        next unless is_standalone

        parent.replace(Nokogiri::HTML5.fragment(youtube_embed_html(id)))
      end
    end

    def drop_empty_paragraphs!(node)
      node.css("p").each do |p|
        text_empty = p.text.to_s.strip.empty?
        no_media = p.css("img, figure, iframe").empty?
        p.remove if text_empty && no_media
      end
    end

    def figure_for_image(url, alt, caption)
      cap_html = caption.present? ? %(<figcaption>#{escape_text(caption)}</figcaption>) : ""
      alt_attr = escape_text(alt.to_s)
      <<~HTML.strip
        <figure class="post-figure" data-image-url="#{escape_text(url)}" data-image-alt="#{alt_attr}">
          <img src="#{escape_text(url)}" alt="#{alt_attr}" loading="lazy">
          #{cap_html}
        </figure>
      HTML
    end

    # We emit a *marker* figure only — `Posts::ContentRenderer` rewrites this
    # into a "Powiązane wideo" link at render time. We deliberately do not
    # emit an <iframe>: youtube-nocookie.com is blocked by Brave/Chromium's
    # default CSP and would render as an ERR_BLOCKED_BY_CSP interstitial.
    def youtube_embed_html(video_id)
      escaped = escape_text(video_id)
      %(<figure class="embed-youtube" data-video-id="#{escaped}"></figure>)
    end

    def youtube_id_from_url(raw_url)
      return nil if raw_url.blank?

      uri = URI.parse(raw_url.strip)
      host = uri.host&.downcase
      return nil unless host && YOUTUBE_HOSTS.include?(host)

      if host == "youtu.be"
        path = uri.path.to_s.sub(%r{\A/}, "")
        return valid_yt_id?(path) ? path : nil
      end

      case uri.path
      when %r{\A/(?:embed|v|shorts)/([\w\-]{6,})}
        return valid_yt_id?(Regexp.last_match(1)) ? Regexp.last_match(1) : nil
      when "/watch"
        params = URI.decode_www_form(uri.query.to_s).to_h
        id = params["v"].to_s
        return valid_yt_id?(id) ? id : nil
      end
      nil
    rescue URI::InvalidURIError
      nil
    end

    def valid_yt_id?(id)
      id.is_a?(String) && id.match?(/\A[\w\-]{6,}\z/)
    end

    def ancestor_figure(node)
      cursor = node.parent
      while cursor && cursor.name != "body"
        return cursor if cursor.name == "figure"
        cursor = cursor.parent
      end
      nil
    end

    def nearest_caption(img)
      figure = ancestor_figure(img)
      return figure.at_css("figcaption")&.text&.strip if figure

      next_sibling = img.parent&.at_css("em, .caption, .photo_text")
      next_sibling&.text&.strip
    end

    def absolutize_image(src)
      return src if src.start_with?("http://", "https://")
      return "https:#{src}" if src.start_with?("//")
      URI.join("https://blogs.pravda.com.ua/", src.sub(%r{\A/}, "")).to_s
    rescue URI::InvalidURIError
      src
    end

    def escape_text(value)
      ERB::Util.html_escape(value.to_s)
    end
  end
end
