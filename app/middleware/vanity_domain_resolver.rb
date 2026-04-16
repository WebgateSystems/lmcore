# frozen_string_literal: true

# Rewrites requests from vanity subdomains (e.g. am.libremedia.org)
# into the canonical /blogs/:slug path so the BlogsController handles them.
#
# Only activates when the Host header contains a subdomain that matches
# a user's vanity_domain. The main domain and localhost are ignored.
class VanityDomainResolver
  MAIN_HOSTS = %w[libremedia.org www.libremedia.org localhost].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    host = env["HTTP_HOST"].to_s.split(":").first.downcase

    if vanity_subdomain?(host)
      user = User.find_by(vanity_domain: host, status: "active")

      if user
        original_path = env["PATH_INFO"]
        env["PATH_INFO"] = "/blogs/#{user.username}#{original_path == '/' ? '' : original_path}"
        env["ORIGINAL_HOST"] = host
      end
    end

    @app.call(env)
  end

  private

  def vanity_subdomain?(host)
    return false if MAIN_HOSTS.include?(host)
    return false if host.match?(/\A\d/) # IP address

    # Has at least one subdomain level (e.g. am.libremedia.org)
    host.count(".") >= 2 || (host.count(".") == 1 && !host.end_with?(".org", ".com", ".net", ".io"))
  end
end
