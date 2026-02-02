source "https://rubygems.org"

ruby "3.4.6"

gem "rails", "~> 8.1.2"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", require: false

# Configuration
gem "config"

# Authentication & Authorization
gem "devise"
gem "devise-jwt"
gem "pundit"
gem "bcrypt", "~> 3.1.7"

# API Documentation
gem "rswag-api"
gem "rswag-ui"

# Background Jobs
gem "redis", ">= 4.0.1"
gem "sidekiq", "~> 8.1"

# File Uploads
gem "carrierwave", "~> 3.0"
gem "mini_magick"

# Views & Templates
gem "slim-rails"
gem "liquid"

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
gem "faraday"
gem "faraday-retry"

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
  gem "capistrano", "~> 3.19", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-rbenv", require: false
  gem "capistrano-sidekiq", require: false
  gem "capistrano3-puma", require: false
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
