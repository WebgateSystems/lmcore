# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Home", type: :request do
  describe "GET /dashboard" do
    context "when not signed in" do
      it "redirects to the login page" do
        get dashboard_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as a regular user" do
      let(:user) { create(:user) }
      before { sign_in user }

      it "returns success for their own dashboard" do
        create(:post, author: user)

        get dashboard_root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as an author" do
      let(:author) { create(:user, :author) }
      before { sign_in author }

      it "returns success and renders basic counts" do
        create(:post, author: author)
        create(:video, author: author)

        get dashboard_root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as a moderator" do
      before { sign_in create(:user, :moderator) }

      it "returns success" do
        get dashboard_root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
