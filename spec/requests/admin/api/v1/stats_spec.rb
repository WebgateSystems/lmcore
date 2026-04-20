# frozen_string_literal: true

require "rails_helper"

# See note in users_spec.rb -- this controller currently has bugs we don't
# fix here (Kaminari pagination, untranslated error helper, calls to a
# non-existent `Video.processing` scope). The auth wall is what we cover.
RSpec.describe "Admin::Api::V1::Stats", type: :request do
  describe "GET /admin/api/v1/stats" do
    it "is unauthorized without a token" do
      get "/admin/api/v1/stats", headers: api_json_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
