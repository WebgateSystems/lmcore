# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Tags", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:tag) { create(:tag) }

  describe "GET /admin/tags" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_tags_path
        expect(response).to have_http_status(:success)
      end

      it "displays tags list" do
        tag
        get admin_tags_path
        expect(response.body).to include("Tags")
      end

      it "searches by name" do
        create(:tag, name: "ruby")
        get admin_tags_path(q: "ruby")
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_tags_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_tags_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/tags/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_tag_path(tag)
        expect(response).to have_http_status(:success)
      end

      it "displays tag details" do
        get admin_tag_path(tag)
        expect(response.body).to include(tag.name)
      end
    end
  end

  describe "GET /admin/tags/new" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get new_admin_tag_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/tags" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:valid_params) do
        {
          tag: {
            name: "newtag"
          }
        }
      end

      it "creates a new tag" do
        expect {
          post admin_tags_path, params: valid_params
        }.to change(Tag, :count).by(1)
      end

      it "redirects to the created tag" do
        post admin_tags_path, params: valid_params
        expect(response).to redirect_to(admin_tag_path(Tag.last))
      end

      it "normalizes tag name to lowercase" do
        post admin_tags_path, params: { tag: { name: "MyTag" } }
        expect(Tag.last.name).to eq("mytag")
      end

      context "with duplicate name" do
        before { create(:tag, name: "existing") }

        it "does not create duplicate tag" do
          expect {
            post admin_tags_path, params: { tag: { name: "existing" } }
          }.not_to change(Tag, :count)
        end

        it "renders new template with error" do
          post admin_tags_path, params: { tag: { name: "existing" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "GET /admin/tags/:id/edit" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get edit_admin_tag_path(tag)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/tags/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:update_params) do
        {
          tag: {
            name: "updatedtag"
          }
        }
      end

      it "updates the tag" do
        patch admin_tag_path(tag), params: update_params
        tag.reload
        expect(tag.name).to eq("updatedtag")
      end

      it "redirects to the tag" do
        patch admin_tag_path(tag), params: update_params
        expect(response).to redirect_to(admin_tag_path(tag))
      end
    end
  end

  describe "DELETE /admin/tags/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "deletes the tag" do
        tag
        expect {
          delete admin_tag_path(tag)
        }.to change(Tag, :count).by(-1)
      end

      it "redirects to tags list" do
        delete admin_tag_path(tag)
        expect(response).to redirect_to(admin_tags_path)
      end
    end
  end
end
