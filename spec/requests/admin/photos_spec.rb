# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Photos", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:photo) { create(:photo, author: admin_user) }

  describe "GET /admin/photos" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_photos_path
        expect(response).to have_http_status(:success)
      end

      it "displays photos list" do
        photo
        get admin_photos_path
        expect(response.body).to include("Photos")
      end

      it "filters by status" do
        create(:photo, author: admin_user, status: "published")
        create(:photo, author: admin_user, status: "draft")

        get admin_photos_path(status: "published")
        expect(response).to have_http_status(:success)
      end

      it "searches by title" do
        create(:photo, author: admin_user, title_i18n: { "en" => "First Photo" })
        get admin_photos_path(q: "First")
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_photos_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_photos_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/photos/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_photo_path(photo)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/photos/new" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get new_admin_photo_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/photos" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:test_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test_image.jpg'), 'image/jpeg') }
      let(:valid_params) do
        {
          photo: {
            title_i18n: { "en" => "Test Photo" },
            description_i18n: { "en" => "Test description" },
            status: "draft",
            image: test_image
          }
        }
      end

      it "creates a new photo" do
        expect {
          post admin_photos_path, params: valid_params
        }.to change(Photo, :count).by(1)
      end

      it "redirects to the created photo" do
        post admin_photos_path, params: valid_params
        expect(response).to redirect_to(admin_photo_path(Photo.last))
      end

      it "sets the current user as author" do
        post admin_photos_path, params: valid_params
        expect(Photo.last.author).to eq(admin_user)
      end
    end
  end

  describe "GET /admin/photos/:id/edit" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get edit_admin_photo_path(photo)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/photos/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:update_params) do
        {
          photo: {
            title_i18n: { "en" => "Updated Title" }
          }
        }
      end

      it "updates the photo" do
        patch admin_photo_path(photo), params: update_params
        photo.reload
        expect(photo.title_i18n["en"]).to eq("Updated Title")
      end

      it "redirects to the photo" do
        patch admin_photo_path(photo), params: update_params
        expect(response).to redirect_to(admin_photo_path(photo))
      end
    end
  end

  describe "DELETE /admin/photos/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "deletes the photo" do
        photo
        expect {
          delete admin_photo_path(photo)
        }.to change(Photo, :count).by(-1)
      end

      it "redirects to photos list" do
        delete admin_photo_path(photo)
        expect(response).to redirect_to(admin_photos_path)
      end
    end
  end

  describe "POST /admin/photos/:id/publish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:draft_photo) { create(:photo, author: admin_user, status: "draft") }

      it "publishes the photo" do
        post publish_admin_photo_path(draft_photo)
        draft_photo.reload
        expect(draft_photo.status).to eq("published")
      end
    end
  end

  describe "POST /admin/photos/:id/unpublish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:published_photo) { create(:photo, author: admin_user, status: "published") }

      it "unpublishes the photo" do
        post unpublish_admin_photo_path(published_photo)
        published_photo.reload
        expect(published_photo.status).to eq("draft")
      end
    end
  end
end
