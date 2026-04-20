# frozen_string_literal: true

module Pravda
  # Walks the paginated author blog index at
  #   https://blogs.pravda.com.ua/authors/<slug>/
  #   https://blogs.pravda.com.ua/authors/<slug>/page_2/
  #   ...
  # and yields each article URL it finds, oldest pages last (the site lists
  # newest first, so we iterate forward; the import service handles ordering).
  class BlogIndexScraper
    ARTICLE_LINK_RE = %r{href="(/authors/[a-z0-9_\-]+/[0-9a-f]{6,}/)"}i
    PAGINATION_RE   = %r{href="/authors/[a-z0-9_\-]+/page_(\d+)/"}i

    attr_reader :author_slug, :http, :max_pages, :start_page

    def initialize(author_slug:,
                   http: Pravda::HttpClient.new,
                   max_pages: nil,
                   start_page: 1)
      @author_slug = author_slug.to_s.tr("/", "")
      @http = http
      @max_pages = max_pages&.to_i
      @start_page = start_page.to_i
    end

    # Returns an Array of absolute article URLs in the order encountered (newest
    # first across pages). De-duplicated.
    def article_urls
      seen = {}
      ordered = []
      total_pages = nil
      page = start_page

      loop do
        page_url = page == 1 ? "/authors/#{author_slug}/" : "/authors/#{author_slug}/page_#{page}/"
        html = http.get_html(page_url)
        total_pages ||= detect_total_pages(html)

        urls_on_page(html).each do |path|
          full_url = absolutize(path)
          next if seen[full_url]
          seen[full_url] = true
          ordered << full_url
        end

        page += 1
        break if total_pages && page > total_pages
        break if max_pages && (page - start_page) >= max_pages
      end

      ordered
    end

    private

    def urls_on_page(html)
      html.scan(ARTICLE_LINK_RE).flatten.uniq
    end

    def detect_total_pages(html)
      pages = html.scan(PAGINATION_RE).flatten.map(&:to_i)
      return nil if pages.empty?
      pages.max
    end

    def absolutize(path)
      URI.join(http.base_url + "/", path.sub(%r{\A/}, "")).to_s
    end
  end
end
