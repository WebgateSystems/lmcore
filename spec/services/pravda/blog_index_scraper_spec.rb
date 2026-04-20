# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pravda::BlogIndexScraper do
  let(:author) { "muzhdabaev" }

  def page_html(article_paths, total_pages: 1, current_page: 1)
    links = article_paths.map { |p| %(<a href="#{p}">x</a>) }.join("\n")
    pagination = (1..total_pages).map { |n| n == current_page ? "" : %(<a href="/authors/#{author}/page_#{n}/">#{n}</a>) }.join
    %(<html><body>#{links}<nav>#{pagination}</nav></body></html>)
  end

  it "collects unique article URLs from a single page" do
    http = instance_double(Pravda::HttpClient, base_url: "https://blogs.pravda.com.ua")
    html = page_html([
      "/authors/#{author}/aaaaaaaaaaaa/",
      "/authors/#{author}/bbbbbbbbbbbb/",
      "/authors/#{author}/aaaaaaaaaaaa/" # duplicate
    ])
    allow(http).to receive(:get_html).with("/authors/#{author}/").and_return(html)

    # max_pages: 1 short-circuits the page loop after the first request --
    # we don't want this test to depend on whether the production scraper
    # auto-detects "this is the only page" from the absence of pagination.
    scraper = described_class.new(author_slug: author, http: http, max_pages: 1)
    urls = scraper.article_urls

    expect(urls).to eq([
      "https://blogs.pravda.com.ua/authors/#{author}/aaaaaaaaaaaa/",
      "https://blogs.pravda.com.ua/authors/#{author}/bbbbbbbbbbbb/"
    ])
  end

  it "walks pagination until total_pages is exhausted" do
    http = instance_double(Pravda::HttpClient, base_url: "https://blogs.pravda.com.ua")
    p1 = page_html([ "/authors/#{author}/111111111111/" ], total_pages: 2, current_page: 1)
    p2 = page_html([ "/authors/#{author}/222222222222/" ], total_pages: 2, current_page: 2)
    allow(http).to receive(:get_html).with("/authors/#{author}/").and_return(p1)
    allow(http).to receive(:get_html).with("/authors/#{author}/page_2/").and_return(p2)

    urls = described_class.new(author_slug: author, http: http).article_urls

    expect(urls.length).to eq(2)
    expect(urls.last).to end_with("/222222222222/")
  end

  it "honors the max_pages cap" do
    http = instance_double(Pravda::HttpClient, base_url: "https://blogs.pravda.com.ua")
    p1 = page_html([ "/authors/#{author}/111111111111/" ], total_pages: 5, current_page: 1)
    allow(http).to receive(:get_html).with("/authors/#{author}/").and_return(p1)

    urls = described_class.new(author_slug: author, http: http, max_pages: 1).article_urls

    expect(urls.length).to eq(1)
    expect(http).to have_received(:get_html).once
  end

  it "strips slashes off the supplied author slug" do
    http = instance_double(Pravda::HttpClient, base_url: "https://blogs.pravda.com.ua")
    allow(http).to receive(:get_html).with("/authors/#{author}/").and_return(page_html([]))

    scraper = described_class.new(author_slug: "/#{author}/", http: http, max_pages: 1)
    expect(scraper.author_slug).to eq(author)
    scraper.article_urls
  end
end
