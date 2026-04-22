# frozen_string_literal: true

require "rails_helper"

# See note in users_spec.rb -- this controller currently has bugs we don't
# fix here (Kaminari pagination, untranslated error helper, `log.details`
# accessor that doesn't exist on the AuditLog model).
RSpec.describe "Admin::Api::V1::Activity", type: :request do
  let(:author_user) { create(:user, :author) }

  describe "GET /admin/api/v1/activity" do
    it "is unauthorized without a token" do
      get "/admin/api/v1/activity", headers: api_json_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "is forbidden for non-admin users" do
      get "/admin/api/v1/activity", headers: api_auth_headers(author_user)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
