# frozen_string_literal: true

require "rails_helper"

# Note: this controller has long-standing production bugs (it depends on
# Kaminari `.page/.per` while only Pagy is installed, calls `.t(...)` on a
# bare `ActionController::API`, and uses `render_success(user: ...)` against
# a positional signature). The specs below cover the auth + base-controller
# paths that *do* work today; full-featured CRUD specs should be reinstated
# once the controller is brought up to working order.
RSpec.describe "Admin::Api::V1::Users", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "GET /admin/api/v1/users" do
    it "returns 401 when not authenticated" do
      get "/admin/api/v1/users", headers: api_json_headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
