# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Pages", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:page_record) { create(:page, author: admin_user) }

  describe "GET /admin/pages" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_pages_path
        expect(response).to have_http_status(:success)
      end

      it "displays pages list" do
        page_record
        get admin_pages_path
        expect(response.body).to include("Pages")
      end

      it "filters by status" do
        create(:page, author: admin_user, status: "published")
        create(:page, author: admin_user, status: "draft")

        get admin_pages_path(status: "published")
        expect(response).to have_http_status(:success)
      end

      it "searches by title" do
        create(:page, author: admin_user, title_i18n: { "en" => "About Us" })
        get admin_pages_path(q: "About")
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_pages_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_pages_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/pages/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_page_path(page_record)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/pages/new" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get new_admin_page_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/pages" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:valid_params) do
        {
          page: {
            title_i18n: { "en" => "Test Page" },
            content_i18n: { "en" => "Test content" },
            status: "draft",
            slug: "test-page"
          }
        }
      end

      it "creates a new page" do
        expect {
          post admin_pages_path, params: valid_params
        }.to change(Page, :count).by(1)
      end

      it "redirects to the created page" do
        post admin_pages_path, params: valid_params
        expect(response).to redirect_to(admin_page_path(Page.last))
      end

      it "sets the current user as author" do
        post admin_pages_path, params: valid_params
        expect(Page.last.author).to eq(admin_user)
      end
    end
  end

  describe "GET /admin/pages/:id/edit" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get edit_admin_page_path(page_record)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/pages/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:update_params) do
        {
          page: {
            title_i18n: { "en" => "Updated Title" }
          }
        }
      end

      it "updates the page" do
        patch admin_page_path(page_record), params: update_params
        page_record.reload
        expect(page_record.title_i18n["en"]).to eq("Updated Title")
      end

      it "redirects to the page" do
        patch admin_page_path(page_record), params: update_params
        expect(response).to redirect_to(admin_page_path(page_record))
      end
    end
  end

  describe "DELETE /admin/pages/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "deletes the page" do
        page_record
        expect {
          delete admin_page_path(page_record)
        }.to change(Page, :count).by(-1)
      end

      it "redirects to pages list" do
        delete admin_page_path(page_record)
        expect(response).to redirect_to(admin_pages_path)
      end
    end
  end

  describe "POST /admin/pages/:id/publish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:draft_page) { create(:page, author: admin_user, status: "draft") }

      it "publishes the page" do
        post publish_admin_page_path(draft_page)
        draft_page.reload
        expect(draft_page.status).to eq("published")
      end
    end
  end

  describe "POST /admin/pages/:id/unpublish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:published_page) { create(:page, author: admin_user, status: "published") }

      it "unpublishes the page" do
        post unpublish_admin_page_path(published_page)
        published_page.reload
        expect(published_page.status).to eq("draft")
      end
    end
  end
end
