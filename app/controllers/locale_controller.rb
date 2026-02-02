# frozen_string_literal: true

class LocaleController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  SUPPORTED_LOCALES = %w[en pl uk lt de fr es].freeze

  def switch
    new_locale = params[:locale].to_s.strip.downcase

    if I18n.available_locales.map(&:to_s).include?(new_locale)
      session[:locale] = new_locale
      cookies[:locale] = { value: new_locale, expires: 1.year.from_now }

      redirect_to build_redirect_url(new_locale), allow_other_host: false
    else
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def build_redirect_url(new_locale)
    referer = request.referer
    return root_path(locale: new_locale) if referer.blank?

    begin
      uri = URI.parse(referer)
      path = uri.path

      # Replace existing locale in path or add new one
      new_path = replace_locale_in_path(path, new_locale)

      # Build the new URL with query string if present
      uri.query.present? ? "#{new_path}?#{uri.query}" : new_path
    rescue URI::InvalidURIError
      root_path(locale: new_locale)
    end
  end

  def replace_locale_in_path(path, new_locale)
    # Match locale at the start of the path: /pl, /en, /uk, etc.
    locale_pattern = %r{^/(#{SUPPORTED_LOCALES.join("|")})(?:/|$)}

    if path.match?(locale_pattern)
      # Replace existing locale with new one
      path.sub(locale_pattern) { |match| match.sub($1, new_locale) }
    elsif path == "/" || path.empty?
      # Root path - add locale
      "/#{new_locale}"
    else
      # No locale in path - prepend new locale
      "/#{new_locale}#{path}"
    end
  end
end
