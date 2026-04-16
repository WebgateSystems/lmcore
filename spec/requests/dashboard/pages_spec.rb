# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Pages", type: :request do
  let(:author) { create(:user, :author) }
  let(:page) { create(:page, author: author) }

  before { sign_in author }

  describe "GET /dashboard/pages" do
    it "renders the index" do
      page
      get dashboard_pages_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/pages" do
    it "re-renders :new when required translations are missing" do
      post dashboard_pages_path, params: {
        page: { title: "", status: "draft", page_type: "custom" }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /dashboard/pages/:id/edit" do
    it "renders the edit form for the owner" do
      get edit_dashboard_page_path(page)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /dashboard/pages/:id" do
    it "updates the page title for the current locale" do
      patch dashboard_page_path(page), params: { page: { title: "Updated title" } }
      expect(response).to redirect_to(dashboard_pages_path)
      expect(page.reload.title_i18n[I18n.locale.to_s]).to eq("Updated title")
    end
  end

  describe "DELETE /dashboard/pages/:id" do
    it "discards the page" do
      page
      delete dashboard_page_path(page)
      expect(response).to redirect_to(dashboard_pages_path)
      expect(page.reload.discarded?).to be true
    end
  end
end
