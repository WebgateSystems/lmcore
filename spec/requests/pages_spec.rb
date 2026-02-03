# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pages", type: :request do
  let(:author) { create(:user) }

  describe "GET /pages/:slug" do
    context "when page exists and is published" do
      let!(:page_record) do
        create(:page,
          author: author,
          slug: "about-us",
          status: "published",
          title_i18n: { "en" => "About Us", "pl" => "O Nas" },
          content_i18n: { "en" => "About content", "pl" => "Treść o nas" }
        )
      end

      it "returns success" do
        get page_path(slug: "about-us")
        expect(response).to have_http_status(:success)
      end

      it "displays page title" do
        get page_path(slug: "about-us")
        expect(response.body).to include("About Us")
      end

      it "displays page content" do
        get page_path(slug: "about-us")
        expect(response.body).to include("About content")
      end

      it "uses landing layout" do
        get page_path(slug: "about-us")
        expect(response.body).to include("<!DOCTYPE html")
      end
    end

    context "when page does not exist" do
      it "returns 404" do
        get "/pages/nonexistent"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when page is draft" do
      let!(:draft_page) { create(:page, author: author, slug: "draft-page", status: "draft") }

      it "shows the page (no authorization check in public controller)" do
        get page_path(slug: "draft-page")
        expect(response).to have_http_status(:success)
      end
    end

    context "with localized content" do
      let!(:page_record) do
        create(:page,
          author: author,
          slug: "contact",
          status: "published",
          title_i18n: { "en" => "Contact", "pl" => "Kontakt" },
          content_i18n: { "en" => "Contact us here", "pl" => "Skontaktuj się z nami" }
        )
      end

      it "displays content in default locale" do
        get page_path(slug: "contact")
        expect(response.body).to include("Contact")
      end
    end
  end
end
