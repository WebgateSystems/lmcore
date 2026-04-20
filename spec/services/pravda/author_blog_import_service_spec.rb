# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pravda::AuthorBlogImportService do
  let(:user) { create(:user, :author) }
  let(:article_url) { "https://blogs.pravda.com.ua/authors/muzhdabaev/69da50522c55e/" }
  let(:html) { File.read(Rails.root.join("spec/fixtures/pravda/sample_article.html")) }

  it "creates a post with a valid slug when title is Cyrillic-only and I18n.default_locale is :en" do
    scraper = instance_double(Pravda::BlogIndexScraper, article_urls: [ article_url ])
    http = instance_double(Pravda::HttpClient)
    allow(http).to receive(:get_html).with(article_url).and_return(html)

    I18n.with_locale(:en) do
      described_class.new(
        user: user,
        author_slug: "muzhdabaev",
        locale: "uk",
        download_images: false,
        http: http,
        scraper: scraper
      ).call
    end

    post = user.posts.order(:created_at).last
    expect(post).to be_present
    expect(post.slug).to be_present
    expect(post.slug).to match(/\A[a-z0-9\-]+\z/)
    expect(post.title(locale: "uk")).to start_with("БІ-БІ-СІТТЕРИ")
  end

  describe "YouTube embed completion" do
    let(:player_url) { "https://blogs.pravda.com.ua/authors/muzhdabaev/65ce58956aab8/" }
    let(:html_with_player) do
      <<~HTML
        <html><body><article class="post">
          <meta property="og:title" content="Player-only post" />
          <header class="post_header">
            <div class="post_time">7 січня 2026, 12:27</div>
            <h1 class="post_title">Player-only post</h1>
          </header>
          <div class="post_text">
            <p>Some intro text.</p>
            <!-- pravda renders the video as a JS web component, only an
                 anchor inside it points at the youtube watch URL -->
            <ytm-watch-player-controls>
              <a class="ytmVideoInfoVideoTitle" href="https://www.youtube.com/watch?v=hNqd3uS3sS4">Title</a>
            </ytm-watch-player-controls>
            <p>Outro paragraph.</p>
          </div>
        </article></body></html>
      HTML
    end

    it "appends a youtube marker figure when the parser only found the ID via a non-standalone link" do
      scraper = instance_double(Pravda::BlogIndexScraper, article_urls: [ player_url ])
      http = instance_double(Pravda::HttpClient)
      allow(http).to receive(:get_html).with(player_url).and_return(html_with_player)

      described_class.new(
        user: user,
        author_slug: "muzhdabaev",
        locale: "uk",
        download_images: false,
        http: http,
        scraper: scraper
      ).call

      post = user.posts.order(:created_at).last
      source = post.content_source_i18n["uk"].to_s
      expect(source).to include('class="embed-youtube"')
      expect(source).to include('data-video-id="hNqd3uS3sS4"')
      # Marker only — no <iframe> at parse/import time.
      expect(source).not_to include('<iframe')
      expect(source).not_to include('youtube-nocookie.com/embed/')
    end
  end
end
