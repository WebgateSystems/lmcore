# frozen_string_literal: true

class Rack::Attack
  # Cache store (use Redis in production)
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle all requests by IP
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Throttle login attempts by IP
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/login" && req.post?
      req.ip
    end
  end

  # Throttle login attempts by email
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/login" && req.post?
      req.params["user"]["email"].to_s.downcase.gsub(/\s+/, "").presence
    end
  end

  # Throttle password reset requests
  throttle("password_reset/ip", limit: 5, period: 1.hour) do |req|
    if req.path == "/password" && req.post?
      req.ip
    end
  end

  # Throttle API requests
  throttle("api/ip", limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Block suspicious requests
  blocklist("block suspicious requests") do |req|
    Rack::Attack::Fail2Ban.filter("fail2ban-#{req.ip}", maxretry: 5, findtime: 10.minutes, bantime: 1.hour) do
      # Block common attack paths but allow legitimate admin routes
      # Legitimate admin: /admin, /admin/*, /api/*/admin/*
      suspicious_admin = req.path.include?("/admin") &&
                         !req.path.start_with?("/admin") &&
                         !req.path.start_with?("/api/")

      req.path.include?("/wp-") ||
        req.path.include?("/phpmyadmin") ||
        req.path.include?(".php") ||
        suspicious_admin
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [ { error: "Rate limit exceeded. Please slow down." }.to_json ]
    ]
  end

  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |_env|
    [
      403,
      { "Content-Type" => "application/json" },
      [ { error: "Access denied." }.to_json ]
    ]
  end
end

# Enable in production
Rails.application.config.middleware.use Rack::Attack unless Rails.env.test?
