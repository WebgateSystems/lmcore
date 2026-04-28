# frozen_string_literal: true

# Rewrites requests addressed to a user's vanity domain into the canonical
# /blogs/:username path so BlogsController handles them.
#
# A "vanity domain" is whatever is stored in users.vanity_domain — this can be:
#   * a subdomain under the main host, e.g. "amg.libremedia.org"
#   * a fully custom domain, e.g. "muzhdabaiev.com"
#
# Implementation notes:
#   * The main host(s) and loopback are always short-circuited.
#   * IP addresses and empty hosts are ignored.
#   * For everything else we ask the database whether the host is a known vanity
#     domain. Results are memoized in a small in-process LRU with a short TTL,
#     so we don't issue a SELECT on every request (and random host scanners
#     don't flood the DB).
class VanityDomainResolver
  MAIN_HOSTS = %w[libremedia.org www.libremedia.org localhost 127.0.0.1 ::1].freeze

  # Cache size and TTL are intentionally small – this is just a buffer against
  # request bursts, not an authoritative cache. Updates to vanity_domain become
  # visible within TTL seconds across all workers without any explicit bust.
  CACHE_TTL       = 30 # seconds
  CACHE_MAX_SIZE  = 1024

  def initialize(app)
    @app = app
    @cache = {}
    @cache_mutex = Mutex.new
  end

  def call(env)
    host = extract_host(env)

    if host && !skip?(host)
      username = lookup_username(host)
      if username
        original_path = env["PATH_INFO"].to_s
        original_query = env["QUERY_STRING"].to_s
        suffix = (original_path == "" || original_path == "/") ? "" : original_path
        env["PATH_INFO"] = "/blogs/#{username}#{suffix}"
        env["ORIGINAL_HOST"] = host
        env["ORIGINAL_FULLPATH"] = original_query.present? ? "#{original_path}?#{original_query}" : original_path
      end
    end

    @app.call(env)
  end

  private

  def extract_host(env)
    raw = env["HTTP_HOST"].to_s
    return nil if raw.empty?

    host = raw.split(":").first.to_s.downcase.strip
    host.empty? ? nil : host
  end

  def skip?(host)
    return true if MAIN_HOSTS.include?(host)
    return true if host.match?(/\A[\d.:a-f]+\z/) && host.match?(/\A\d|\A::|:/) # IPv4/IPv6-ish
    false
  end

  def lookup_username(host)
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    cached = @cache_mutex.synchronize { @cache[host] }
    if cached && cached[:expires_at] > now
      return cached[:username]
    end

    username = fetch_username(host)

    @cache_mutex.synchronize do
      # naive eviction: drop everything when we hit the cap
      @cache.clear if @cache.size >= CACHE_MAX_SIZE
      @cache[host] = { username: username, expires_at: now + CACHE_TTL }
    end

    username
  end

  # NOTE: we intentionally do NOT filter by `vanity_domain_verified` here yet –
  # there is no end-to-end DNS verification flow in the app, and the flag
  # defaults to false for historical users. Once a verification workflow is
  # in place, add `.where(vanity_domain_verified: true)` below.
  def fetch_username(host)
    return nil unless defined?(User) && User.respond_to?(:where)

    User.where(vanity_domain: host, status: "active").pick(:username)
  rescue ActiveRecord::StatementInvalid, ActiveRecord::ConnectionNotEstablished
    nil
  end
end
