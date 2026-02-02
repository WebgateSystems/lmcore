# frozen_string_literal: true

class LocaleController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def switch
    locale = params[:locale].to_s.strip.downcase

    if I18n.available_locales.map(&:to_s).include?(locale)
      session[:locale] = locale
      cookies[:locale] = { value: locale, expires: 1.year.from_now }
    end

    redirect_back(fallback_location: root_path)
  end
end
