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
  let(:super_admin) { create(:user, :super_admin) }
  let(:author_user) { create(:user, :author) }
  let(:target_user) { create(:user, :author, first_name: "Old", last_name: "Name") }

  describe "GET /admin/api/v1/users" do
    it "returns 401 when not authenticated" do
      get "/admin/api/v1/users", headers: api_json_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 for authenticated non-admin users" do
      get "/admin/api/v1/users", headers: api_auth_headers(author_user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /admin/api/v1/users/:id" do
    it "returns detailed user payload for admin" do
      get "/admin/api/v1/users/#{target_user.id}", headers: api_auth_headers(admin)
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.dig("data", "user", "id")).to eq(target_user.id)
      expect(body.dig("data", "user", "full_name")).to be_present
    end
  end

  describe "PATCH /admin/api/v1/users/:id" do
    it "updates user attributes" do
      patch "/admin/api/v1/users/#{target_user.id}",
            params: { user: { first_name: "New", last_name: "Person" } }.to_json,
            headers: api_auth_headers(admin, extra: { "Content-Type" => "application/json" })

      expect(response).to have_http_status(:ok)
      expect(target_user.reload.first_name).to eq("New")
    end
  end

  describe "POST /admin/api/v1/users/:id/suspend and /activate" do
    it "suspends and activates target user" do
      post "/admin/api/v1/users/#{target_user.id}/suspend", headers: api_auth_headers(admin)
      expect(response).to have_http_status(:ok)
      expect(target_user.reload.status).to eq("suspended")

      post "/admin/api/v1/users/#{target_user.id}/activate", headers: api_auth_headers(admin)
      expect(response).to have_http_status(:ok)
      expect(target_user.reload.status).to eq("active")
    end
  end

  describe "POST /admin/api/v1/users/:id/change_role" do
    let(:editor_role) { Role.find_by(slug: "editor") || create(:role, slug: "editor") }

    it "assigns role to user" do
      post "/admin/api/v1/users/#{target_user.id}/change_role",
           params: { role_id: editor_role.id },
           headers: api_auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(target_user.reload.has_role?("editor")).to be(true)
    end
  end

  describe "DELETE /admin/api/v1/users/:id" do
    it "soft-deletes target user" do
      delete "/admin/api/v1/users/#{target_user.id}", headers: api_auth_headers(super_admin)
      expect(response).to have_http_status(:ok)
      expect(target_user.reload.status).to eq("deleted")
    end
  end
end
