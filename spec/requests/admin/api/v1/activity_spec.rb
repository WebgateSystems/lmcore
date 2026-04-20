# frozen_string_literal: true

require "rails_helper"

# See note in users_spec.rb -- this controller currently has bugs we don't
# fix here (Kaminari pagination, untranslated error helper, `log.details`
# accessor that doesn't exist on the AuditLog model).
RSpec.describe "Admin::Api::V1::Activity", type: :request do
  describe "GET /admin/api/v1/activity" do
    it "is unauthorized without a token" do
      get "/admin/api/v1/activity", headers: api_json_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
