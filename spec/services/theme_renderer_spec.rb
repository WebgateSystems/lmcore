# frozen_string_literal: true

require "rails_helper"
require "fileutils"

RSpec.describe ThemeRenderer do
  let(:theme_slug) { "rspec-theme" }
  let(:theme_path) { Rails.root.join("themes", theme_slug) }

  before do
    FileUtils.mkdir_p(theme_path.join("layouts"))
    FileUtils.mkdir_p(theme_path.join("partials"))
    FileUtils.mkdir_p(theme_path.join("nested"))
    File.write(theme_path.join("layouts/application.liquid"), "<layout>{{ content }}</layout>")
    File.write(theme_path.join("index.liquid"), "hello {{ blog.name }}")
    File.write(theme_path.join("nested/page.liquid"), "nested {{ title }}")
    File.write(theme_path.join("partials/banner.liquid"), "[banner for {{ name }}]")
    File.write(theme_path.join("includes.liquid"), "{% include 'banner' %}")
  end

  after do
    FileUtils.rm_rf(theme_path)
  end

  describe "#render" do
    it "wraps template content with the application layout" do
      out = described_class.new(theme_slug).render("index", { blog: { name: "LM" } })
      expect(out).to eq("<layout>hello LM</layout>")
    end

    it "supports nested templates and skipping the layout" do
      out = described_class.new(theme_slug).render("nested/page", { title: "Hello" }, layout: nil)
      expect(out).to eq("nested Hello")
    end

    it "resolves partials from the partials directory" do
      out = described_class.new(theme_slug).render("includes", { name: "LM" }, layout: nil)
      expect(out).to eq("[banner for LM]")
    end

    it "raises TemplateNotFound when a template is missing" do
      expect {
        described_class.new(theme_slug).render("missing", {})
      }.to raise_error(ThemeRenderer::TemplateNotFound)
    end
  end

  describe "#template_exists?" do
    let(:renderer) { described_class.new(theme_slug) }

    it "returns true for existing templates" do
      expect(renderer.template_exists?("index")).to be true
    end

    it "returns false for missing templates" do
      expect(renderer.template_exists?("nope")).to be false
    end
  end

  describe "BlogFilters" do
    subject(:filters) { Object.new.extend(ThemeRenderer::BlogFilters) }

    describe "#truncate_words" do
      it "truncates long strings with ellipsis" do
        text = "one two three four five six seven"
        expect(filters.truncate_words(text, 3)).to eq("one two three...")
      end

      it "returns the original string when short enough" do
        expect(filters.truncate_words("one two", 5)).to eq("one two")
      end

      it "handles nil input" do
        expect(filters.truncate_words(nil)).to eq("")
      end
    end

    describe "#strip_html" do
      it "removes HTML tags and collapses whitespace" do
        html = "<p>Hello <strong>world</strong></p><br/><div>foo</div>"
        expect(filters.strip_html(html)).to eq("Hello world foo")
      end
    end

    describe "#reading_time" do
      it "computes estimated minutes based on word count" do
        text = ("word " * 401).strip
        expect(filters.reading_time(text)).to eq("3 min")
      end

      it "handles nil input" do
        expect(filters.reading_time(nil)).to eq("1 min")
      end
    end

    describe "#excerpt" do
      it "returns the text when shorter than the limit" do
        expect(filters.excerpt("short text", 200)).to eq("short text")
      end

      it "appends ellipsis when truncated" do
        text = "a " * 150
        expect(filters.excerpt(text, 50)).to end_with("...")
      end
    end
  end

  describe "DateFilters" do
    subject(:filters) { Object.new.extend(ThemeRenderer::DateFilters) }

    describe "#date_format" do
      it "formats a Time object" do
        expect(filters.date_format(Time.utc(2024, 5, 4, 10, 0, 0))).to eq("04.05.2024")
      end

      it "parses ISO strings" do
        expect(filters.date_format("2024-05-04", "%Y")).to eq("2024")
      end

      it "returns empty string for nil" do
        expect(filters.date_format(nil)).to eq("")
      end
    end

    describe "#time_ago" do
      it "returns 'just now' for recent times" do
        expect(filters.time_ago(10.seconds.ago)).to eq("just now")
      end

      it "returns minutes ago bucket" do
        expect(filters.time_ago(5.minutes.ago)).to match(/\A\d+ minutes ago\z/)
      end
    end
  end

  describe "UrlFilters" do
    let(:renderer) { described_class.new(theme_slug) }

    before do
      File.write(theme_path.join("links.liquid"),
        "{{ 'x' | post_url }}|{{ 'v' | video_url }}|{{ 'p' | photo_url }}|" \
        "{{ 't' | tag_url }}|{{ 'c' | category_url }}|{{ 's' | page_url }}")
    end

    it "prefixes slugs with the context base_path" do
      out = renderer.render("links", { "base_path" => "/blogs/am" }, layout: nil)
      expect(out).to eq(
        "/blogs/am/posts/x|/blogs/am/videos/v|/blogs/am/gallery/p|" \
        "/blogs/am/tags/t|/blogs/am/categories/c|/blogs/am/pages/s"
      )
    end
  end

  describe "AssetFilters" do
    let(:renderer) { described_class.new(theme_slug) }

    before do
      File.write(theme_path.join("assets.liquid"),
        "{{ 'style.css' | theme_asset }}|{{ 'style.css' | stylesheet_tag }}|{{ 'app.js' | javascript_tag }}")
    end

    it "prefixes theme_asset with /themes/:slug and emits tags" do
      out = renderer.render("assets", { "theme_slug" => "custom" }, layout: nil)
      expect(out).to eq(
        "/themes/custom/style.css|<link rel=\"stylesheet\" href=\"/themes/custom/style.css\">" \
        "|<script src=\"/themes/custom/app.js\"></script>"
      )
    end

    it "falls back to default slug when not provided" do
      out = renderer.render("assets", {}, layout: nil)
      expect(out).to include("/themes/default/style.css")
    end
  end

  describe "I18nFilters" do
    let(:renderer) { described_class.new(theme_slug) }

    before do
      File.write(theme_path.join("i18n.liquid"), "{{ 'dashboard.navigation.posts' | t }}")
    end

    it "translates keys using the I18n backend" do
      out = renderer.render("i18n", {}, layout: nil)
      expect(out).to eq("Posts")
    end
  end
end
