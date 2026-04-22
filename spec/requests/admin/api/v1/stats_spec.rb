# frozen_string_literal: true

require "rails_helper"

# See note in users_spec.rb -- this controller currently has bugs we don't
# fix here (Kaminari pagination, untranslated error helper, calls to a
# non-existent `Video.processing` scope). The auth wall is what we cover.
RSpec.describe "Admin::Api::V1::Stats", type: :request do
  let(:author_user) { create(:user, :author) }

  describe "GET /admin/api/v1/stats" do
    it "is unauthorized without a token" do
      get "/admin/api/v1/stats", headers: api_json_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "is forbidden for non-admin users" do
      get "/admin/api/v1/stats", headers: api_auth_headers(author_user)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
