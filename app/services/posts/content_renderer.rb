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
    ].freeze

    ALLOWED_ATTRIBUTES = {
      "a"          => %w[href target rel title],
      "img"        => %w[src alt loading width height class],
      "figure"     => %w[class data-attachment-id],
      "figcaption" => %w[class],
      "span"       => %w[class],
      "div"        => %w[class],
      "th"         => %w[scope colspan rowspan],
      "td"         => %w[colspan rowspan],
      "blockquote" => %w[cite],
      "code"       => %w[class],
      "pre"        => %w[class]
    }.freeze

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

        format = post.content_format.to_s.presence || "html"
        html   = format == "markdown" ? render_markdown(text) : text
        html   = expand_inline_attachments(html, post, locale)
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

        return html unless html.include?("data-attachment-id")

        attachments_by_id = preload_attachments(post, html)

        doc = Nokogiri::HTML5.fragment(html)
        doc.css("figure[data-attachment-id]").each do |fig|
          id = fig["data-attachment-id"]
          attachment = attachments_by_id[id]
          if attachment
            replacement = Nokogiri::HTML5.fragment(figure_for(attachment, locale))
            fig.replace(replacement)
          else
            # Attachment was deleted/unknown - drop the placeholder silently
            fig.remove
          end
        end
        doc.to_html
      end

      def figure_for(attachment, locale)
        url     = attachment_url(attachment)
        alt     = lookup_translation(attachment.alt_text_i18n, locale)
        caption = lookup_translation(attachment.caption_i18n, locale)
        title   = lookup_translation(attachment.title_i18n, locale)
        alt_value = alt.presence || title.presence || ""

        cap_html = caption.present? ? %(<figcaption>#{ERB::Util.html_escape(caption)}</figcaption>) : ""

        [
          %(<figure class="post-figure" data-attachment-id="#{attachment.id}">),
          %(<img src="#{ERB::Util.html_escape(url)}" alt="#{ERB::Util.html_escape(alt_value)}" loading="lazy">),
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
        doc.css("script, style, iframe, object, embed, link, meta, base, form, input, textarea, button, select").each(&:remove)
        doc.to_html
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
