# frozen_string_literal: true

redis_url = Settings.redis_url.presence || "redis://localhost:6379/0"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Configure server middleware
  config.server_middleware do |chain|
    # Add custom middleware here if needed
  end

  # Set up logging (default INFO in all environments, override with SIDEKIQ_LOG_LEVEL=debug)
  configured_level = ENV.fetch("SIDEKIQ_LOG_LEVEL", "info").to_s.upcase
  config.logger.level = Logger.const_defined?(configured_level) ? Logger.const_get(configured_level) : Logger::INFO
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# Default job options
Sidekiq.default_job_options = {
  "retry" => 3,
  "backtrace" => true
}
