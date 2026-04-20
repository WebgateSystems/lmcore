# frozen_string_literal: true

require "rails_helper"

RSpec.describe Posts::ContentRenderer do
  let(:author) { create(:user, :author) }
  let(:post)   { create(:post, author: author, content_format: "html") }

  describe ".render" do
    context "with HTML source" do
      it "passes safe HTML through and sanitizes script tags" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => "<h2>Title</h2><p>Hello <strong>world</strong></p><script>alert(1)</script>"
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include("<h2>Title</h2>")
        expect(rendered).to include("<strong>world</strong>")
        expect(rendered).not_to include("<script>")
        expect(rendered).not_to include("alert(1)")
      end

      it "preserves figure with data-attachment-id when expanding inline images" do
        attachment = create(:media_attachment, user: author, attachable: post,
                                               attachment_type: "image",
                                               alt_text_i18n: { "en" => "An alt" },
                                               caption_i18n: { "en" => "A caption" })

        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<p>Before</p><figure data-attachment-id="#{attachment.id}"></figure><p>After</p>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include(%(data-attachment-id="#{attachment.id}"))
        expect(rendered).to include("<img")
        expect(rendered).to include('alt="An alt"')
        expect(rendered).to include("<figcaption>A caption</figcaption>")
      end

      it "removes the placeholder when the attachment does not exist" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<p>x</p><figure data-attachment-id="00000000-0000-0000-0000-000000000000"></figure><p>y</p>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include("<p>x</p>")
        expect(rendered).to include("<p>y</p>")
        expect(rendered).not_to include("data-attachment-id")
      end

      it "falls back to the remote image URL when an attachment-bound figure has a data-image-url hint" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<figure data-attachment-id="00000000-0000-0000-0000-000000000000" data-image-url="https://blogimg.pravda.com/img.jpg" data-image-alt="Foto"></figure>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include('src="https://blogimg.pravda.com/img.jpg"')
        expect(rendered).to include('alt="Foto"')
        expect(rendered).to include('referrerpolicy="no-referrer"')
      end

      it "renders a remote-image figure for a parser-only data-image-url placeholder" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<figure class="post-figure" data-image-url="https://blogimg.pravda.com/x.jpg" data-image-alt="Cap"><img src="https://blogimg.pravda.com/x.jpg" alt="Cap"></figure>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include('src="https://blogimg.pravda.com/x.jpg"')
        expect(rendered).to include('referrerpolicy="no-referrer"')
        # the parser-emitted source attribute is gone, only the rendered figure remains
        expect(rendered.scan('<img').size).to eq(1)
      end

      it "rewrites inline YouTube embeds into a Powiązane wideo link" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<p>Intro</p><figure class="embed-youtube" data-video-id="abc123"><iframe src="https://www.youtube-nocookie.com/embed/abc123" allowfullscreen></iframe></figure>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include('class="section-article-item__related-video"')
        expect(rendered).to include('class="post-content-link"')
        expect(rendered).to include('href="https://www.youtube.com/watch?v=abc123"')
        expect(rendered).to include('target="_blank"')
        expect(rendered).not_to include("<iframe")
        expect(rendered).not_to include("embed-youtube")
      end

      it "rewrites a bare data-video-id figure (no iframe) into the same link" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<p>Intro</p><figure class="embed-youtube" data-video-id="xyz999"></figure>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include('href="https://www.youtube.com/watch?v=xyz999"')
        expect(rendered).not_to include("<iframe")
      end

      it "rewrites a stand-alone YouTube iframe (legacy content) into the link" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<p>before</p><iframe src="https://www.youtube-nocookie.com/embed/legacy01" allowfullscreen></iframe><p>after</p>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include('href="https://www.youtube.com/watch?v=legacy01"')
        expect(rendered).not_to include("<iframe")
      end

      it "unwraps single-img <div> wrappers from imported HTML" do
        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<p>before</p><div><img src="https://blogimg.pravda.com/y.jpg" alt=""></div><p>after</p>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        # the wrapper div with no class is gone, the img remains at top level
        expect(rendered).to include("<img")
        expect(rendered).not_to match(%r{<div>\s*<img})
      end
    end

    context "with Markdown source" do
      it "renders Markdown into HTML" do
        post.content_format = "markdown"
        post.content_source_i18n = {
          "en" => "# Header\n\n**bold** and *italic*\n\n- item 1\n- item 2"
        }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include("<h1>Header</h1>")
        expect(rendered).to include("<strong>bold</strong>")
        expect(rendered).to include("<em>italic</em>")
        expect(rendered).to include("<li>item 1</li>")
      end

      it "expands [[fig:UUID]] shortcode into a figure" do
        attachment = create(:media_attachment, user: author, attachable: post,
                                               attachment_type: "image",
                                               alt_text_i18n: { "en" => "Alt" },
                                               caption_i18n: { "en" => "Cap" })

        post.content_format = "markdown"
        post.content_source_i18n = { "en" => "Para 1\n\n[[fig:#{attachment.id}]]\n\nPara 2" }
        post.save!

        rendered = post.content_i18n["en"]
        expect(rendered).to include("Para 1")
        expect(rendered).to include("Para 2")
        expect(rendered).to include(%(data-attachment-id="#{attachment.id}"))
        expect(rendered).to include("<img")
        expect(rendered).to include("Cap")
      end
    end

    context "translation lookup" do
      it "uses the requested locale for alt and caption" do
        attachment = create(:media_attachment,
                            user: author,
                            attachable: post,
                            attachment_type: "image",
                            alt_text_i18n: { "en" => "EN alt", "pl" => "PL alt" },
                            caption_i18n: { "en" => "EN cap", "pl" => "PL cap" })

        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<figure data-attachment-id="#{attachment.id}"></figure>),
          "pl" => %(<figure data-attachment-id="#{attachment.id}"></figure>)
        }
        post.save!

        expect(post.content_i18n["en"]).to include('alt="EN alt"')
        expect(post.content_i18n["en"]).to include("<figcaption>EN cap</figcaption>")
        expect(post.content_i18n["pl"]).to include('alt="PL alt"')
        expect(post.content_i18n["pl"]).to include("<figcaption>PL cap</figcaption>")
      end

      it "falls back to default locale when missing" do
        attachment = create(:media_attachment,
                            user: author,
                            attachable: post,
                            attachment_type: "image",
                            alt_text_i18n: { "en" => "EN alt" },
                            caption_i18n: { "en" => "EN cap" })

        post.content_format = "html"
        post.content_source_i18n = {
          "uk" => %(<figure data-attachment-id="#{attachment.id}"></figure>)
        }
        post.save!

        expect(post.content_i18n["uk"]).to include('alt="EN alt"')
      end
    end

    context "edge cases" do
      it "returns empty string for blank source" do
        expect(described_class.render(post, "en", source: "")).to eq("")
      end

      it "is safe for content with HTML entities and quotes in caption" do
        attachment = create(:media_attachment,
                            user: author,
                            attachable: post,
                            attachment_type: "image",
                            alt_text_i18n: { "en" => %(an "alt" & more) },
                            caption_i18n: { "en" => %(<script>x</script>"a" & b) })

        post.content_format = "html"
        post.content_source_i18n = {
          "en" => %(<figure data-attachment-id="#{attachment.id}"></figure>)
        }
        post.save!

        rendered = post.content_i18n["en"]
        # XSS payload from the caption must be neutralised: no executable
        # <script> tag survives anywhere in the output.
        expect(rendered).not_to match(/<script[\s>]/)

        # `<` `>` `&` from the caption end up entity-encoded inside the
        # figcaption text node.
        expect(rendered).to include("&lt;script&gt;")
        expect(rendered).to include("&amp;")

        # The alt attribute is a well-formed HTML attribute that round-trips
        # through Nokogiri (which may pick `"` or `'` as the delimiter
        # depending on payload). Either way, the original `"alt"` text must
        # be intact in the parsed alt value, NOT closing the attribute early
        # and breaking the document structure.
        doc = Nokogiri::HTML.fragment(rendered)
        img = doc.at_css("img")
        expect(img).to be_present
        expect(img["alt"]).to include(%(an "alt" & more))
      end
    end
  end

  describe ".render_markdown" do
    it "supports tables" do
      html = described_class.render_markdown("| a | b |\n|---|---|\n| 1 | 2 |\n")
      expect(html).to include("<table>")
      expect(html).to include("<td>1</td>")
    end

    it "supports fenced code blocks" do
      html = described_class.render_markdown("```\nfoo\n```\n")
      expect(html).to include("<pre>")
      expect(html).to include("<code>foo")
    end
  end

  describe ".sanitize" do
    it "strips disallowed tags but keeps inner text" do
      out = described_class.sanitize("<iframe src='evil'></iframe><p>safe</p>")
      expect(out).not_to include("<iframe")
      expect(out).to include("<p>safe</p>")
    end

    it "keeps figure with data-attachment-id" do
      out = described_class.sanitize(%(<figure data-attachment-id="abc"><img src="/x.png" alt="x"></figure>))
      expect(out).to include("<figure")
      expect(out).to include('data-attachment-id="abc"')
      expect(out).to include("<img")
    end
  end
end
