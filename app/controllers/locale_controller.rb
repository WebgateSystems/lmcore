# frozen_string_literal: true

class LocaleController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # Path prefixes that may appear after the leading slash (canonical + UA alias for uk)
  PATH_PREFIX_LOCALES = %w[en pl uk ua lt de fr es ru].freeze

  def switch
    raw = params[:locale].to_s.strip.downcase
    canonical = LocaleTags.canonical_locale_code(raw)

    if canonical.present? && I18n.available_locales.map(&:to_s).include?(canonical)
      session[:locale] = canonical
      cookies[:locale] = { value: canonical, expires: 1.year.from_now }

      redirect_to build_redirect_url(canonical), allow_other_host: false
    else
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def build_redirect_url(canonical_locale)
    referer = request.referer
    seg = LocaleTags.path_segment_for_canonical(canonical_locale)
    return root_path(locale: seg) if referer.blank?

    begin
      uri = URI.parse(referer)
      path = uri.path

      new_path = replace_locale_in_path(path, canonical_locale)

      uri.query.present? ? "#{new_path}?#{uri.query}" : new_path
    rescue URI::InvalidURIError
      root_path(locale: seg)
    end
  end

  def replace_locale_in_path(path, canonical_locale)
    new_seg = LocaleTags.path_segment_for_canonical(canonical_locale)
    locale_pattern = %r{^/(#{PATH_PREFIX_LOCALES.join("|")})(?:/|$)}

    if path.match?(locale_pattern)
      path.sub(locale_pattern) { |match| match.sub($1, new_seg) }
    elsif path == "/" || path.empty?
      "/#{new_seg}"
    else
      "/#{new_seg}#{path}"
    end
  end
end
