# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pravda::ArticleParser do
  let(:article_url) { "https://blogs.pravda.com.ua/authors/muzhdabaev/69da50522c55e/" }
  let(:sample_html) { File.read(Rails.root.join("spec/fixtures/pravda/sample_article.html")) }
  let(:media_html) { File.read(Rails.root.join("spec/fixtures/pravda/article_with_media.html")) }

  describe "with a real captured Pravda article" do
    subject(:parsed) { described_class.new(html: sample_html, url: article_url).call }

    it "extracts the canonical URL and external_id" do
      expect(parsed[:canonical_url]).to eq(article_url)
      expect(parsed[:external_id]).to eq("muzhdabaev/69da50522c55e")
    end

    it "extracts the title from og:title" do
      expect(parsed[:title]).to start_with("БІ-БІ-СІТТЕРИ ПУТІНА")
    end

    it "extracts the lead from og:description" do
      expect(parsed[:lead]).to be_a(String).and(be_present)
      expect(parsed[:lead]).to include("Російська служба ВВС")
    end

    it "parses the published_at timestamp" do
      expect(parsed[:published_at]).to be_a(Time)
      expect(parsed[:published_at].year).to eq(2026)
      expect(parsed[:published_at].month).to eq(4)
      expect(parsed[:published_at].day).to eq(11)
    end

    it "parses the views_count" do
      expect(parsed[:views_count]).to be_a(Integer).and(be > 0)
    end

    it "extracts the category name in Ukrainian" do
      expect(parsed[:category_name_uk]).to eq("Політика")
    end

    it "extracts the featured image URL" do
      expect(parsed[:featured_image_url]).to start_with("https://blogimg.pravda.com/")
    end

    it "produces clean HTML stripped of the disclaimer paragraph" do
      expect(parsed[:content_html]).not_to include("Блог автора")
      expect(parsed[:content_html]).not_to include("class=\"hl3\"")
      expect(parsed[:content_html]).not_to include("data-io-article-url")
    end
  end

  describe "with images and YouTube embeds" do
    subject(:parsed) { described_class.new(html: media_html, url: "https://blogs.pravda.com.ua/authors/muzhdabaev/aabbccddeeff/").call }

    it "rewrites <img> into <figure data-image-url> placeholders" do
      expect(parsed[:content_html]).to include('<figure class="post-figure"')
      expect(parsed[:content_html]).to include('data-image-url="https://blogimg.pravda.com/images/doc/1/2/inline-photo.jpg"')
      expect(parsed[:content_html]).to include('alt="Підпис фото"')
    end

    it "exposes images for downloading" do
      expect(parsed[:images]).to contain_exactly(
        a_hash_including(
          src: "https://blogimg.pravda.com/images/doc/1/2/inline-photo.jpg",
          alt: "Підпис фото"
        )
      )
    end

    it "converts iframe YouTube embeds into a marker figure (no iframe)" do
      expect(parsed[:content_html]).to include('class="embed-youtube"')
      expect(parsed[:content_html]).to include('data-video-id="ygAotYpyHUs"')
      # We no longer emit an <iframe> at parse time — Brave/Chromium block
      # youtube-nocookie embeds via CSP, so the renderer turns this marker
      # into a "Powiązane wideo" link instead.
      expect(parsed[:content_html]).not_to include('<iframe')
      expect(parsed[:content_html]).not_to include('youtube-nocookie.com/embed/')
    end

    it "converts standalone YouTube text links into a marker figure" do
      expect(parsed[:content_html]).to include('data-video-id="dQw4w9WgXcQ"')
    end

    it "collects all unique YouTube video IDs" do
      expect(parsed[:youtube_video_ids]).to contain_exactly("ygAotYpyHUs", "dQw4w9WgXcQ")
    end

    it "drops the pravda disclaimer paragraph" do
      expect(parsed[:content_html]).not_to include("Блог автора")
    end

    it "removes inline data-io-article-url tracking attributes" do
      expect(parsed[:content_html]).not_to include("data-io-article-url")
    end
  end

  describe "with images wrapped in a bare <div>" do
    let(:html) do
      <<~HTML
        <html><body><article class="post">
          <div class="post_time">11 квітня 2026, 16:44</div>
          <h1 class="post_title">div-wrapped image</h1>
          <div class="post_text">
            <p>Intro</p>
            <div><img src="https://blogimg.pravda.com/images/doc/0/a/0aaff-img03029.jpeg"></div>
            <p>Outro</p>
          </div>
        </article></body></html>
      HTML
    end

    it "replaces the wrapping div with the figure (no leftover empty <div>)" do
      parsed = described_class.new(html: html).call
      expect(parsed[:content_html]).to include('<figure class="post-figure"')
      expect(parsed[:content_html]).to include('data-image-url="https://blogimg.pravda.com/images/doc/0/a/0aaff-img03029.jpeg"')
      expect(parsed[:content_html]).not_to match(%r{<div>\s*<figure})
    end
  end

  describe "date parsing" do
    let(:html) do
      <<~HTML
        <html><body><article class="post">
          <div class="post_time">7 січня 2026, 12:27</div>
          <h1 class="post_title">x</h1>
          <div class="post_text"><p>x</p></div>
        </article></body></html>
      HTML
    end

    it "supports all 12 Ukrainian month names" do
      Pravda::ArticleParser::UA_MONTHS.each do |ua_name, expected_month|
        body = html.sub("січня", ua_name)
        parsed = described_class.new(html: body).call
        expect(parsed[:published_at]&.month).to eq(expected_month), "expected #{ua_name} -> month #{expected_month}"
      end
    end
  end
end
