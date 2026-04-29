# frozen_string_literal: true

require "omniauth"

OmniAuth.config.full_host = lambda do |env|
  if Rails.env.production?
    Settings.sso.issuer.to_s.chomp("/")
  else
    request = Rack::Request.new(env)
    "#{request.scheme}://#{request.host_with_port}"
  end
end
