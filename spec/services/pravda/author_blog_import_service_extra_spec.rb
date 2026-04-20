# frozen_string_literal: true

require "rails_helper"

# Targets the slug-generation, attachment-binding, and orphan-youtube-embed
# helpers inside Pravda::AuthorBlogImportService. The base spec covers the
# happy path; this one focuses on the private/branching surface so that the
# service edges land in the coverage report.
RSpec.describe Pravda::AuthorBlogImportService do
  let(:user) { create(:user, :author) }
  let(:scraper) { instance_double(Pravda::BlogIndexScraper, article_urls: []) }
  let(:http) { instance_double(Pravda::HttpClient) }

  let(:service) do
    described_class.new(
      user: user,
      author_slug: "muzhdabaev",
      locale: "uk",
      download_images: false,
      http: http,
      scraper: scraper
    )
  end

  describe "#slug_base_from_import" do
    it "uses the title parameterized with the import locale" do
      base = service.send(:slug_base_from_import, { title: "Hello World", external_id: "abc/123" })
      expect(base).to eq("hello-world")
    end

    it "falls back to :uk parameterize for non-uk locales when the first attempt is empty" do
      svc = described_class.new(user: user, author_slug: "x", locale: "en",
                                download_images: false, http: http, scraper: scraper)
      base = svc.send(:slug_base_from_import, { title: "Привіт", external_id: "abc/123" })
      expect(base).not_to be_empty
      expect(base).to match(/\A[a-z0-9\-]+\z/)
    end

    it "ultimately falls back to the external_id when nothing parameterizes" do
      base = service.send(:slug_base_from_import, { title: "", external_id: "muzhdabaev/abc1234" })
      expect(base).to be_present
      expect(base).to match(/\A[a-z0-9\-]+\z/)
    end

    it "returns 'pravda' when both title and external_id are blank" do
      base = service.send(:slug_base_from_import, { title: "", external_id: "" })
      expect(base).to eq("pravda")
    end
  end

  describe "#unique_slug_for_author" do
    it "returns the base when no collision exists" do
      post = user.posts.new
      expect(service.send(:unique_slug_for_author, post, "fresh")).to eq("fresh")
    end

    it "increments counter suffix on collisions" do
      create(:post, author: user, slug: "dup")
      create(:post, author: user, slug: "dup-1")
      post = user.posts.new
      expect(service.send(:unique_slug_for_author, post, "dup")).to eq("dup-2")
    end
  end

  describe "#append_orphan_youtube_embeds" do
    it "appends marker figures for ids missing from the html" do
      html = '<p>Hello</p>'
      out = service.send(:append_orphan_youtube_embeds, html, %w[abc XYZ])
      expect(out).to include('class="embed-youtube"')
      expect(out).to include('data-video-id="abc"')
      expect(out).to include('data-video-id="XYZ"')
    end

    it "skips ids already present in the html" do
      html = '<figure class="embed-youtube" data-video-id="already"></figure>'
      out = service.send(:append_orphan_youtube_embeds, html, %w[already])
      expect(out.scan('data-video-id="already"').size).to eq(1)
    end

    it "is a no-op when video_ids is blank" do
      expect(service.send(:append_orphan_youtube_embeds, "<p>x</p>", [])).to eq("<p>x</p>")
      expect(service.send(:append_orphan_youtube_embeds, "<p>x</p>", nil)).to eq("<p>x</p>")
    end
  end

  describe "#bind_attachments_into_html" do
    let(:post) { create(:post, author: user) }
    let(:attachment) { create(:media_attachment, attachable: post, user: user, attachment_type: "image") }

    it "rewrites figure[data-image-url] into figure[data-attachment-id] when matched" do
      url = "https://example.com/img.jpg"
      html = %(<figure data-image-url="#{url}" data-image-alt="alt"><img src="#{url}"/></figure>)
      out = service.send(:bind_attachments_into_html, html, { url => attachment })
      expect(out).to include(%(data-attachment-id="#{attachment.id}"))
      expect(out).not_to include("data-image-url")
      expect(out).not_to include("data-image-alt")
    end

    it "leaves figures untouched when no attachment matches" do
      html = %(<figure data-image-url="missing"><img/></figure>)
      out = service.send(:bind_attachments_into_html, html, {})
      expect(out).to include("data-image-url")
    end

    it "returns html as-is when blank" do
      expect(service.send(:bind_attachments_into_html, "", {})).to eq("")
    end
  end

  describe "#mime_for" do
    it "maps common extensions to the correct mime type" do
      expect(service.send(:mime_for, "pic.png")).to eq("image/png")
      expect(service.send(:mime_for, "pic.gif")).to eq("image/gif")
      expect(service.send(:mime_for, "pic.webp")).to eq("image/webp")
      expect(service.send(:mime_for, "pic.jpeg")).to eq("image/jpeg")
      expect(service.send(:mime_for, "pic.JPG")).to eq("image/jpeg")
      expect(service.send(:mime_for, "noext")).to eq("image/jpeg")
    end
  end

  describe "#youtube_embed_html" do
    it "html-escapes the video id into the marker figure" do
      out = service.send(:youtube_embed_html, %(<bad>&"))
      expect(out).to include("&lt;bad&gt;&amp;&quot;")
      expect(out).to start_with('<figure class="embed-youtube"')
    end
  end

  describe "#resolve_category" do
    it "returns nil when no category_slug and no name_uk are given" do
      expect(service.send(:resolve_category, nil)).to be_nil
    end

    it "uses category_slug.find_by when given" do
      cat = create(:category, user: user, slug: "media")
      svc = described_class.new(user: user, author_slug: "x", locale: "uk",
                                category_slug: "media",
                                download_images: false, http: http, scraper: scraper)
      expect(svc.send(:resolve_category, "Anything")).to eq(cat)
    end

    it "matches by name_i18n->>'uk' when no category_slug is set" do
      cat = create(:category, user: user, name_i18n: { "uk" => "Політика", "en" => "Politics" })
      expect(service.send(:resolve_category, "Політика")).to eq(cat)
    end
  end

  describe "#emit error swallowing" do
    it "does not raise when the progress callback explodes" do
      logger = instance_double(Logger, info: nil, warn: nil, error: nil)
      svc = described_class.new(user: user, author_slug: "x", locale: "uk",
                                download_images: false, http: http, scraper: scraper,
                                progress: ->(*) { raise "boom" }, logger: logger)
      expect { svc.send(:emit, :start) }.not_to raise_error
      expect(logger).to have_received(:warn).with(/progress callback raised/)
    end
  end

  describe "#call" do
    it "respects max_articles by capping the discovered URL list" do
      allow(scraper).to receive(:article_urls).and_return(
        Array.new(5) { |i| "https://blogs.pravda.com.ua/authors/x/abcdef#{i}/" }
      )
      svc = described_class.new(user: user, author_slug: "x", locale: "uk",
                                max_articles: 2,
                                download_images: false, http: http, scraper: scraper)
      allow(http).to receive(:get_html).and_return("<html><body><article class='post'></article></body></html>")
      stats = svc.call
      expect(stats[:total]).to eq(2)
    end

    it "tracks errors when the http client raises" do
      allow(scraper).to receive(:article_urls).and_return([
        "https://blogs.pravda.com.ua/authors/x/abcdef0/"
      ])
      allow(http).to receive(:get_html).and_raise("network down")
      stats = service.call
      expect(stats[:errors]).to eq(1)
    end

    it "skips articles with empty title or content" do
      allow(scraper).to receive(:article_urls).and_return([
        "https://blogs.pravda.com.ua/authors/x/abcdef0/"
      ])
      allow(http).to receive(:get_html).and_return("<html></html>")
      stats = service.call
      expect(stats[:skipped]).to eq(1)
    end
  end

  describe "fixtures-driven happy path with media" do
    let(:html) do
      path = Rails.root.join("spec/fixtures/pravda/article_with_media.html")
      File.exist?(path) ? File.read(path) : nil
    end

    it "imports an article and returns :created when the fixture exists" do
      skip "no media fixture present" if html.nil?

      url = "https://blogs.pravda.com.ua/authors/x/abc1234/"
      allow(scraper).to receive(:article_urls).and_return([ url ])
      allow(http).to receive(:get_html).with(url).and_return(html)

      stats = service.call
      expect(stats[:created] + stats[:updated]).to be >= 1
    end
  end
end
