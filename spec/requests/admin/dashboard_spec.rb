# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Dashboard", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "GET /admin" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end

      it "displays dashboard content" do
        get admin_root_path
        expect(response.body).to include("Dashboard")
      end

      it "shows statistics" do
        # Create some content to show stats
        create_list(:user, 3)
        create_list(:post, 2, author: admin_user)

        get admin_root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_root_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
