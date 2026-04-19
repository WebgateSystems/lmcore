# frozen_string_literal: true

module ApiAuthHelpers
  # Generate a JWT for an API user via devise-jwt's encoder so request specs can
  # hit Api::V1 controllers without going through the full login flow.
  # We always tag the request as JSON so Devise's failure_app returns 401 for
  # unauthenticated requests instead of redirecting to the HTML sign-in page.
  def api_auth_headers(user = nil, extra: {})
    base = { "Accept" => "application/json" }
    if user
      token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      base["Authorization"] = "Bearer #{token}"
    end
    base.merge(extra)
  end

  def api_json_headers(extra: {})
    { "Accept" => "application/json" }.merge(extra)
  end
end

RSpec.configure do |config|
  config.include ApiAuthHelpers, type: :request
end
