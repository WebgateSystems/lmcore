# frozen_string_literal: true

# Canonical I18n / DB locale codes stay standard (e.g. :uk for Ukrainian YAML).
# URL segments and UI badges use "ua" for Ukrainian (ISO 3166-1 style), not "uk".
module LocaleTags
  CANONICAL_ALIASES = { "ua" => "uk" }.freeze

  UI_TAG_BY_CANONICAL = {
    "en" => "EN",
    "pl" => "PL",
    "uk" => "UA",
    "lt" => "LT",
    "de" => "DE",
    "fr" => "FR",
    "es" => "ES",
    "ru" => "RU"
  }.freeze

  NATIVE_NAME_BY_CANONICAL = {
    "en" => "English",
    "pl" => "Polski",
    "uk" => "Українська",
    "lt" => "Lietuvių",
    "de" => "Deutsch",
    "fr" => "Français",
    "es" => "Español",
    "ru" => "Русский"
  }.freeze

  # Public home layout only — not every entry in I18n.available_locales (e.g. admin/profile may offer more).
  HOME_LANGUAGE_SWITCHER_LOCALES = %i[en pl uk lt].freeze

  class << self
    def home_language_switcher_locales
      HOME_LANGUAGE_SWITCHER_LOCALES.select { |l| I18n.available_locales.include?(l) }
    end
    def canonical_locale_code(raw)
      return nil if raw.blank?

      c = raw.to_s.strip.downcase
      CANONICAL_ALIASES[c] || c
    end

    def path_segment_for_canonical(canonical_code)
      c = canonical_code.to_s
      return "ua" if c == "uk"

      c
    end

    def ui_tag(locale)
      c = canonical_locale_code(locale)
      UI_TAG_BY_CANONICAL[c] || c&.upcase || ""
    end

    def native_name(locale)
      c = canonical_locale_code(locale)
      NATIVE_NAME_BY_CANONICAL[c] || c&.upcase || ""
    end

    def menu_label(locale)
      c = canonical_locale_code(locale)
      "#{ui_tag(c)} #{native_name(c)}".strip
    end
  end
end
