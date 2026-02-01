# frozen_string_literal: true

module Translatable
  extend ActiveSupport::Concern

  class_methods do
    # Define translatable attributes that use JSONB columns with _i18n suffix
    # Usage: translates :title, :description
    def translates(*attrs)
      attrs.each do |attr|
        # Getter - returns value for current locale or fallback
        define_method(attr) do |locale: I18n.locale|
          translations = send("#{attr}_i18n") || {}
          translations[locale.to_s] || translations[I18n.default_locale.to_s] || translations.values.first
        end

        # Setter - sets value for current locale
        define_method("#{attr}=") do |value, locale: I18n.locale|
          translations = send("#{attr}_i18n") || {}
          translations[locale.to_s] = value
          send("#{attr}_i18n=", translations)
        end

        # Get all translations
        define_method("#{attr}_translations") do
          send("#{attr}_i18n") || {}
        end

        # Set translation for specific locale
        define_method("set_#{attr}") do |value, locale:|
          translations = send("#{attr}_i18n") || {}
          translations[locale.to_s] = value
          send("#{attr}_i18n=", translations)
        end

        # Check if translation exists for locale
        define_method("#{attr}_translated?") do |locale: I18n.locale|
          translations = send("#{attr}_i18n") || {}
          translations[locale.to_s].present?
        end
      end
    end
  end
end
