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

    it "updates page content for the current locale" do
      patch dashboard_page_path(page), params: { page: { content: "<p>Updated content</p>" } }
      expect(response).to redirect_to(dashboard_pages_path)
      expect(page.reload.content_i18n[I18n.locale.to_s]).to eq("<p>Updated content</p>")
    end

    it "updates translated fields from i18n hashes" do
      patch dashboard_page_path(page), params: {
        page: {
          title_i18n: { "en" => "About EN", "uk" => "About UK" },
          content_i18n: { "en" => "<p>EN content</p>", "uk" => "<p>UK content</p>" },
          meta_description_i18n: { "en" => "EN meta", "uk" => "UK meta" }
        }
      }

      expect(response).to redirect_to(dashboard_pages_path)
      updated = page.reload
      expect(updated.title_i18n.slice("en", "uk")).to eq({ "en" => "About EN", "uk" => "About UK" })
      expect(updated.content_i18n.slice("en", "uk")).to eq({ "en" => "<p>EN content</p>", "uk" => "<p>UK content</p>" })
      expect(updated.meta_description_i18n.slice("en", "uk")).to eq({ "en" => "EN meta", "uk" => "UK meta" })
    end

    it "converts markdown content to html when markdown format is selected" do
      patch dashboard_page_path(page), params: {
        page: {
          content_format: "markdown",
          content_i18n: { "en" => "# Header\n\nBody paragraph" }
        }
      }

      expect(response).to redirect_to(dashboard_pages_path)
      expect(page.reload.content_i18n["en"]).to include("<h1>Header</h1>")
      expect(page.reload.content_i18n["en"]).to include("<p>Body paragraph</p>")
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
