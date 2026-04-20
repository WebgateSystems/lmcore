# frozen_string_literal: true

require "faraday"
require "faraday/retry"

module Pravda
  # Thin Faraday wrapper for blogs.pravda.com.ua. Pravda's edge serves a
  # very stripped-down "you look like a bot, go away" page when the request
  # does not look like a real browser, so we send a full set of browser
  # headers and back off aggressively on 403/429.
  #
  # The site is encoded in windows-1251 -- responses are transcoded to UTF-8
  # before being returned.
  class HttpClient
    DEFAULT_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
                         "AppleWebKit/537.36 (KHTML, like Gecko) " \
                         "Chrome/124.0.0.0 Safari/537.36"

    DEFAULT_HEADERS = {
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language" => "uk-UA,uk;q=0.9,en;q=0.7,pl;q=0.5",
      "Accept-Encoding" => "identity",
      "Cache-Control" => "no-cache",
      "Pragma" => "no-cache",
      "Connection" => "keep-alive",
      "Upgrade-Insecure-Requests" => "1"
    }.freeze

    BOT_PAGE_MARKER = "you look like a bot"

    attr_reader :base_url, :user_agent, :sleep_between, :timeout

    def initialize(base_url: "https://blogs.pravda.com.ua",
                   user_agent: DEFAULT_USER_AGENT,
                   sleep_between: 1.5,
                   timeout: 30,
                   open_timeout: 10,
                   max_retries: 4,
                   retry_base_delay: 2.0,
                   logger: Rails.logger)
      @base_url = base_url
      @user_agent = user_agent
      @sleep_between = sleep_between.to_f
      @timeout = timeout
      @open_timeout = open_timeout
      @max_retries = max_retries
      @retry_base_delay = retry_base_delay.to_f
      @logger = logger
      @last_request_at = nil
    end

    # GET an absolute URL or path on `base_url`. Returns the decoded UTF-8
    # response body or raises on persistent failure.
    def get_html(url_or_path)
      url = absolute_url(url_or_path)
      throttle!

      attempt = 0
      begin
        attempt += 1
        response = connection.get(url) do |req|
          DEFAULT_HEADERS.each { |k, v| req.headers[k] = v }
          req.headers["Referer"] = base_url + "/"
        end

        @last_request_at = Time.now

        if response.status.between?(500, 599) || response.status == 429 || response.status == 403
          raise RateLimited, "HTTP #{response.status}"
        end
        raise NotFound, "HTTP 404 for #{url}" if response.status == 404
        unless response.success?
          raise Error, "Unexpected HTTP #{response.status} for #{url}"
        end

        body = transcode_body(response)
        if body.to_s.strip.downcase.start_with?(BOT_PAGE_MARKER)
          raise RateLimited, "bot detection page returned"
        end

        body
      rescue RateLimited, Faraday::TimeoutError, Faraday::ConnectionFailed => e
        if attempt > @max_retries
          raise Error, "Giving up on #{url} after #{attempt} attempts: #{e.message}"
        end
        backoff = @retry_base_delay * (2**(attempt - 1))
        @logger&.warn("[Pravda] #{e.class}: #{e.message} — sleeping #{backoff.round(1)}s and retrying (#{attempt}/#{@max_retries})")
        sleep(backoff)
        retry
      end
    end

    # Download a binary asset (image). Returns the raw body or nil on 404.
    def get_binary(url)
      throttle!
      response = connection.get(url) do |req|
        DEFAULT_HEADERS.each { |k, v| req.headers[k] = v }
        req.headers["Accept"] = "image/avif,image/webp,image/apng,image/*,*/*;q=0.8"
        req.headers["Referer"] = base_url + "/"
      end
      @last_request_at = Time.now
      return nil if response.status == 404
      raise Error, "HTTP #{response.status} for #{url}" unless response.success?

      response.body
    end

    class Error < StandardError; end
    class NotFound < Error; end
    class RateLimited < Error; end

    private

    def absolute_url(url_or_path)
      return url_or_path if url_or_path.to_s.start_with?("http://", "https://")

      URI.join(base_url + "/", url_or_path.to_s.sub(%r{\A/}, "")).to_s
    end

    def connection
      @connection ||= Faraday.new do |c|
        c.headers["User-Agent"] = user_agent
        c.options.timeout = @timeout
        c.options.open_timeout = @open_timeout
      end
    end

    def throttle!
      return unless @last_request_at && @sleep_between.positive?

      delta = Time.now - @last_request_at
      remaining = @sleep_between - delta
      sleep(remaining) if remaining.positive?
    end

    def transcode_body(response)
      ctype = response.headers["content-type"].to_s
      body = response.body.to_s

      # NOTE: use `match` (not `match?`) here -- `match?` does NOT populate
      # `Regexp.last_match`, so the previous version silently fell through
      # to "windows-1251" even when the headers explicitly said utf-8 and
      # mojibake'd UTF-8 responses. Captured groups have to come from a real
      # MatchData.
      encoding = ctype.match(/charset=([^;\s]+)/i)&.[](1)
      encoding ||= body[0, 2048].match(/charset=([\w\-]+)/i)&.[](1)
      encoding = (encoding || "windows-1251").downcase
      body.force_encoding(encoding).encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
    rescue Encoding::ConverterNotFoundError
      body.force_encoding("UTF-8")
    end
  end
end
