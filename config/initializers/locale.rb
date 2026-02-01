# frozen_string_literal: true

# Available locales
I18n.available_locales = %i[en pl uk lt de fr es]

# Default locale
I18n.default_locale = :en

# Load path for locale files
I18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]

# Fallback to English if translation is missing
I18n.fallbacks = true
