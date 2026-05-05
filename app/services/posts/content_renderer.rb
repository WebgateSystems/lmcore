# frozen_string_literal: true

module Posts
  # Renders a post's source content (HTML or Markdown) into a sanitized HTML
  # blob ready to be embedded in a Liquid template.
  #
  # Inline images are referenced from the source as either:
  #   * Markdown shortcode:  [[fig:UUID]]
  #   * HTML placeholder:    <figure data-attachment-id="UUID"></figure>
  #
  # Both forms are expanded into a full <figure>/<img>/<figcaption> tree using
  # the actual MediaAttachment record (so caption + alt are translated per
  # locale and the image URL stays in sync if the file is re-uploaded).
  #
  # Sanitization happens last with an explicit allowlist of tags/attributes.
  class ContentRenderer
    ALLOWED_TAGS = %w[
      h1 h2 h3 h4 h5 h6
      p br hr
      blockquote
      ul ol li
      strong em b i u s sub sup mark
      a img figure figcaption
      pre code kbd samp var
      span div
      table thead tbody tfoot tr th td caption
      iframe
    ].freeze

    ALLOWED_ATTRIBUTES = {
      "a"          => %w[href target rel title class data-src data-sub-html],
      "img"        => %w[src alt loading width height class referrerpolicy data-attachment-id],
      "figure"     => %w[class data-attachment-id data-video-id data-image-url data-image-alt],
      "figcaption" => %w[class],
      "span"       => %w[class],
      "div"        => %w[class],
      "th"         => %w[scope colspan rowspan],
      "td"         => %w[colspan rowspan],
      "blockquote" => %w[cite],
      "code"       => %w[class],
      "pre"        => %w[class],
      "iframe"     => %w[src width height frameborder allow allowfullscreen loading title referrerpolicy]
    }.freeze

    # Hosts allowed in <iframe src="...">. Anything else is stripped wholesale
    # by `strip_unsafe_blocks` so the public blog cannot accidentally embed
    # an attacker-controlled origin.
    #
    # YouTube is intentionally NOT on this list — Brave/Chromium block
    # `youtube-nocookie.com` via CSP and render an ugly ERR_BLOCKED_BY_CSP
    # interstitial inside the embed. We rewrite every YouTube reference to a
    # plain "Powiązane wideo" link in `expand_inline_video_embeds`.
    ALLOWED_IFRAME_HOSTS = %w[
      player.vimeo.com vimeo.com
    ].freeze

    PLACEHOLDER_REGEX = /\[\[fig:([0-9a-f-]{8,36})\]\]/i

    class << self
      # @param post   [Post]
      # @param locale [String, Symbol]
      # @param source [String, nil] override (used by `Post#rerender_content_per_locale!`
      #   to render a value that is not yet persisted into `content_source_i18n`).
      def render(post, locale, source: nil)
        locale = locale.to_s
        text   = (source || post.content_source_i18n[locale]).to_s
        return "" if text.blank?

        format = post.respond_to?(:content_format) ? post.content_format.to_s.presence : nil
        format ||= "html"
        html   = format == "markdown" ? render_markdown(text) : text
        html   = expand_inline_attachments(html, post, locale)
        html   = expand_inline_video_embeds(html)
        sanitize(html)
      end

      def render_markdown(text)
        renderer = Redcarpet::Render::HTML.new(
          filter_html: false,
          hard_wrap: true,
          link_attributes: { rel: "nofollow noopener" }
        )
        markdown = Redcarpet::Markdown.new(
          renderer,
          autolink: true,
          tables: true,
          fenced_code_blocks: true,
          strikethrough: true,
          superscript: true,
          no_intra_emphasis: true,
          space_after_headers: true
        )
        markdown.render(text.to_s)
      end

      def expand_inline_attachments(html, post, locale)
        # 1) Markdown shortcode -> empty placeholder element.
        html = html.gsub(PLACEHOLDER_REGEX) { %(<figure data-attachment-id="#{Regexp.last_match(1)}"></figure>) }

        needs_attachment_pass = html.include?("data-attachment-id")
        needs_image_url_pass  = html.include?("data-image-url")
        needs_div_unwrap      = html.include?("<div") && html.include?("<img")
        return html unless needs_attachment_pass || needs_image_url_pass || needs_div_unwrap

        attachments_by_id = needs_attachment_pass ? preload_attachments(post, html) : {}

        doc = Nokogiri::HTML5.fragment(html)

        if needs_attachment_pass
          doc.css("figure[data-attachment-id]").each do |fig|
            id = fig["data-attachment-id"]
            attachment = attachments_by_id[id]
            if attachment
              replacement = Nokogiri::HTML5.fragment(figure_for(attachment, locale))
              fig.replace(replacement)
            else
              # No local copy exists. Fall back to the original remote URL the
              # parser stored on the figure so the image still renders for
              # readers (e.g. when the import job could not download the file).
              fallback_url = fig["data-image-url"].to_s
              if fallback_url.present?
                fig.replace(Nokogiri::HTML5.fragment(remote_image_figure(fallback_url, fig["data-image-alt"].to_s)))
              else
                fig.remove
              end
            end
          end

          doc.css("img[data-attachment-id]").each do |img|
            next if img.ancestors("figure[data-attachment-id]").any?

            id = img["data-attachment-id"]
            attachment = attachments_by_id[id]
            attachment ? img.replace(Nokogiri::HTML5.fragment(figure_for(attachment, locale))) : img.remove
          end
        end

        if needs_image_url_pass
          doc.css("figure[data-image-url]").each do |fig|
            next if fig["data-attachment-id"].present?
            url = fig["data-image-url"].to_s
            next if url.blank?
            fig.replace(Nokogiri::HTML5.fragment(remote_image_figure(url, fig["data-image-alt"].to_s)))
          end
        end

        # Some imported sources (Pravda) wrap inline images in a bare
        # <div><img></div> (or <div><figure></div> after the parser pass).
        # Unwrap those so the image obeys the same layout rules as the
        # figure-based ones.
        doc.css("div").each do |div|
          next if div["class"].to_s.strip.present?
          children = div.children.reject { |c| c.text? && c.text.strip.empty? }
          next unless children.size == 1
          only = children.first
          next unless only.element? && %w[img figure].include?(only.name)
          div.replace(only)
        end

        doc.to_html
      end

      # Renders a stand-alone <figure>/<img> for a remote image URL. The
      # `referrerpolicy="no-referrer"` defeats hot-link blocking that some
      # CDNs (e.g. blogimg.pravda.com) apply when the Referer header points
      # to a third-party origin.
      def remote_image_figure(url, alt)
        alt_value = alt.to_s
        [
          %(<figure class="post-figure post-figure--lightbox">),
          %(<a class="post-figure__lightbox" href="#{ERB::Util.html_escape(url)}" data-src="#{ERB::Util.html_escape(url)}">),
          %(<img src="#{ERB::Util.html_escape(url)}" alt="#{ERB::Util.html_escape(alt_value)}" loading="lazy" referrerpolicy="no-referrer">),
          "</a>",
          "</figure>"
        ].join
      end

      # Replaces every YouTube reference inside the post body with a clean
      # "Powiązane wideo" link pointing straight at YouTube. We deliberately
      # do NOT iframe-embed the video: youtube-nocookie.com is blocked by
      # default in Brave / Chromium with strict CSP and shows the
      # ERR_BLOCKED_BY_CSP interstitial inside our page, which looks broken.
      # A simple outbound link works for everyone.
      #
      # Inputs we normalise here:
      #   * `<figure class="embed-youtube" data-video-id="X">…</figure>`
      #     (what the parser writes for new imports)
      #   * `<figure data-video-id="X">…</figure>` without the helper class
      #   * a stand-alone `<iframe src="…/embed/X">` left over from older
      #     imports that still live in `content_source_i18n`
      def expand_inline_video_embeds(html)
        return html unless html.include?("embed-youtube") || html.include?("data-video-id") || html.include?("youtu")

        doc = Nokogiri::HTML5.fragment(html)

        doc.css("figure.embed-youtube, figure[data-video-id]").each do |fig|
          id = fig["data-video-id"].to_s.presence ||
               youtube_id_from_url(fig.at_css("iframe")&.[]("src").to_s) ||
               youtube_id_from_url(fig.at_css("a")&.[]("href").to_s)
          next if id.blank?

          fig.replace(Nokogiri::HTML5.fragment(youtube_link_html(id)))
        end

        # Lone <iframe> still pointing at YouTube (legacy content with no
        # surrounding figure wrapper) — turn it into the same link.
        doc.css("iframe").each do |frame|
          id = youtube_id_from_url(frame["src"].to_s)
          next if id.blank?
          frame.replace(Nokogiri::HTML5.fragment(youtube_link_html(id)))
        end

        doc.to_html
      end

      def youtube_link_html(video_id)
        escaped = ERB::Util.html_escape(video_id)
        label   = ERB::Util.html_escape(I18n.t("themes.am.content.related_video", default: I18n.t("content.related_video", default: "Related video")))
        url     = "https://www.youtube.com/watch?v=#{escaped}"
        %(<p class="section-article-item__related-video"><a class="post-content-link" href="#{url}" target="_blank" rel="noopener noreferrer">#{label}.</a></p>)
      end

      def youtube_id_from_url(raw_url)
        return nil if raw_url.blank?

        uri = URI.parse(raw_url.to_s.strip)
        host = uri.host&.downcase
        return nil unless host

        youtube_hosts = %w[
          www.youtube.com youtube.com m.youtube.com
          youtu.be
          www.youtube-nocookie.com youtube-nocookie.com
        ]
        return nil unless youtube_hosts.include?(host)

        if host == "youtu.be"
          path = uri.path.to_s.sub(%r{\A/}, "")
          return path if path.match?(/\A[\w\-]{6,}\z/)
          return nil
        end

        case uri.path
        when %r{\A/(?:embed|v|shorts)/([\w\-]{6,})}
          return Regexp.last_match(1)
        when "/watch"
          params = URI.decode_www_form(uri.query.to_s).to_h
          id = params["v"].to_s
          return id if id.match?(/\A[\w\-]{6,}\z/)
        end
        nil
      rescue URI::InvalidURIError
        nil
      end

      def figure_for(attachment, locale)
        url     = attachment_url(attachment)
        alt     = lookup_translation(attachment.alt_text_i18n, locale)
        caption = lookup_translation(attachment.caption_i18n, locale)
        title   = lookup_translation(attachment.title_i18n, locale)
        alt_value = alt.presence || title.presence || ""

        cap_html = caption.present? ? %(<figcaption>#{ERB::Util.html_escape(caption)}</figcaption>) : ""

        [
          %(<figure class="post-figure post-figure--lightbox" data-attachment-id="#{attachment.id}">),
          %(<a class="post-figure__lightbox" href="#{ERB::Util.html_escape(full_attachment_url(attachment))}" data-src="#{ERB::Util.html_escape(full_attachment_url(attachment))}">),
          %(<img src="#{ERB::Util.html_escape(url)}" alt="#{ERB::Util.html_escape(alt_value)}" loading="lazy">),
          "</a>",
          cap_html,
          "</figure>"
        ].join
      end

      def sanitize(html)
        return "" if html.blank?

        # Rails::Html::SafeListSanitizer with an explicit `tags:` allowlist
        # removes disallowed elements but keeps their text content. For
        # `<script>`/`<style>`/`<iframe>` etc. we want the content gone too,
        # so we pre-strip those wholesale before the allowlist pass.
        cleaned = strip_unsafe_blocks(html)

        Rails::Html::SafeListSanitizer.new.sanitize(
          cleaned,
          tags: ALLOWED_TAGS,
          attributes: flat_allowed_attributes
        )
      end

      def strip_unsafe_blocks(html)
        doc = Nokogiri::HTML5.fragment(html)
        doc.css("script, style, object, embed, link, meta, base, form, input, textarea, button, select").each(&:remove)
        doc.css("iframe").each do |frame|
          frame.remove unless allowed_iframe_src?(frame["src"])
        end
        doc.to_html
      end

      def allowed_iframe_src?(src)
        return false if src.blank?

        uri = URI.parse(src.to_s.strip)
        return false unless uri.scheme && %w[http https].include?(uri.scheme.downcase)

        ALLOWED_IFRAME_HOSTS.include?(uri.host&.downcase)
      rescue URI::InvalidURIError
        false
      end

      private

      def preload_attachments(post, html)
        ids = html.scan(/data-attachment-id="([^"]+)"/).flatten.uniq
        return {} if ids.empty?

        post.media_attachments.where(id: ids).index_by { |a| a.id.to_s }
      end

      def attachment_url(attachment)
        # MediaUploader defines :medium and :thumb versions for images.
        # Fall back to the original file URL if the version is missing.
        if attachment.respond_to?(:file) && attachment.file.respond_to?(:url)
          version_url(attachment, :medium) || attachment.file.url.to_s
        else
          ""
        end
      end

      def full_attachment_url(attachment)
        if attachment.respond_to?(:file) && attachment.file.respond_to?(:url)
          attachment.file.url.to_s
        else
          attachment_url(attachment)
        end
      end

      def version_url(attachment, version)
        versioned = attachment.file.public_send(version)
        return nil if versioned.blank?

        url = versioned.respond_to?(:url) ? versioned.url : nil
        url.presence
      rescue NoMethodError
        nil
      end

      def lookup_translation(hash, locale)
        return "" unless hash.is_a?(Hash)

        locale = locale.to_s
        hash[locale].presence ||
          hash[I18n.default_locale.to_s].presence ||
          hash.values.compact.find(&:present?).to_s
      end

      def flat_allowed_attributes
        # Rails::Html::SafeListSanitizer accepts a flat array of attribute names
        # (applied to all tags). To keep our per-tag intent readable above we
        # collapse the per-tag map into a unique array here.
        ALLOWED_ATTRIBUTES.values.flatten.uniq
      end
    end
  end
end
