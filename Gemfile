source "https://rubygems.org"

ruby "3.4.6"

gem "rails", "~> 8.1.2", ">= 8.1.2.1" # CVE-2026-33658 (Active Storage proxy DoS)
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", require: false

# `actiontext` ships an unpinned `~> 2.1.15` constraint that resolves to the
# vulnerable 2.1.16. Pin to >= 2.1.18 to pick up the XSS fixes
# (GHSA-53p3-c7vp-4mcc, GHSA-qmpg-8xg6-ph5q).
gem "action_text-trix", ">= 2.1.18"

# Configuration
gem "config"

# Authentication & Authorization
gem "devise", ">= 5.0.3" # CVE-2026-32700 (Confirmable email change race)
gem "devise-jwt"
gem "pundit"
gem "bcrypt", "~> 3.1.7", ">= 3.1.22" # CVE-2026-33306 (zero-iteration overflow on JRuby)

# API Documentation
gem "rswag-api"
gem "rswag-ui"

# Background Jobs
gem "redis", ">= 4.0.1"
gem "sidekiq", "~> 7.0"
gem "connection_pool", "< 4.0"

# File Uploads
gem "carrierwave", "~> 3.0"
gem "mini_magick"

# Views & Templates
gem "slim-rails"
gem "liquid"

# Markdown rendering for post content
gem "redcarpet", "~> 3.6"

# I18n & Translations
gem "mobility", "~> 1.3"
gem "mobility-ransack"

# Search
gem "pg_search"
gem "elasticsearch", "~> 8.0"
gem "searchkick"

# Caching & Performance
gem "oj"
gem "multi_json"

# UUID support for PostgreSQL
gem "pgcrypto"

# Pagination
gem "pagy", "~> 9.0"

# Soft delete
gem "discard", "~> 1.3"

# State machines
gem "aasm"

# HTTP clients
gem "faraday", ">= 2.14.1" # CVE-2026-25765 (SSRF via protocol-relative URL)
gem "faraday-retry"

# Pinned transitive dependencies — these are pulled in by Rails / Sidekiq /
# Nokogiri etc., but we hard-pin minimum versions here so `bundler-audit`
# stays green on CI without waiting for an upstream release.
gem "rack", ">= 3.2.5" # CVE-2026-22860 (directory traversal), CVE-2026-25500 (XSS)
gem "nokogiri", ">= 1.19.1" # GHSA-wx95-c6cv-8532 (xmlC14NExecute return value)
gem "loofah", ">= 2.25.1" # GHSA-46fp-8f5p-pf2m (allowed_uri? bypass)
gem "json", ">= 2.19.2" # CVE-2026-33210 (format string injection)

# Observability
gem "lograge"
gem "semantic_logger"

# Security
gem "rack-attack"
gem "secure_headers"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  # Testing
  gem "rspec-rails", "~> 7.0"
  gem "rswag-specs"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end

group :development do
  gem "web-console"
  gem "annotaterb"
  gem "letter_opener"
  gem "bullet"

  # Deployment
  gem "capistrano", "~> 3.20", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano3-puma", github: "seuros/capistrano-puma"
  gem "capistrano-hook", require: false
  gem "capistrano-nvm", require: false
  gem "capistrano-rvm"
end

group :test do
  gem "simplecov", require: false
  gem "webmock"
  gem "vcr"
  gem "timecop"
  gem "pundit-matchers"
  gem "capybara"
  gem "selenium-webdriver"
end
