# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Videos", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:video) { create(:video, author: admin_user) }

  describe "GET /admin/videos" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_videos_path
        expect(response).to have_http_status(:success)
      end

      it "displays videos list" do
        video
        get admin_videos_path
        expect(response.body).to include("Videos")
      end

      it "filters by status" do
        create(:video, author: admin_user, status: "published")
        create(:video, author: admin_user, status: "draft")

        get admin_videos_path(status: "published")
        expect(response).to have_http_status(:success)
      end

      it "searches by title" do
        create(:video, author: admin_user, title_i18n: { "en" => "First Video" })
        get admin_videos_path(q: "First")
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_videos_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_videos_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/videos/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_video_path(video)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/videos/new" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get new_admin_video_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/videos" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:valid_params) do
        {
          video: {
            title_i18n: { "en" => "Test Video" },
            description_i18n: { "en" => "Test description" },
            status: "draft",
            video_provider: "youtube",
            video_external_id: "dQw4w9WgXcQ"
          }
        }
      end

      it "creates a new video" do
        expect {
          post admin_videos_path, params: valid_params
        }.to change(Video, :count).by(1)
      end

      it "redirects to the created video" do
        post admin_videos_path, params: valid_params
        expect(response).to redirect_to(admin_video_path(Video.last))
      end

      it "sets the current user as author" do
        post admin_videos_path, params: valid_params
        expect(Video.last.author).to eq(admin_user)
      end
    end
  end

  describe "GET /admin/videos/:id/edit" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get edit_admin_video_path(video)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/videos/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:update_params) do
        {
          video: {
            title_i18n: { "en" => "Updated Title" }
          }
        }
      end

      it "updates the video" do
        patch admin_video_path(video), params: update_params
        video.reload
        expect(video.title_i18n["en"]).to eq("Updated Title")
      end

      it "redirects to the video" do
        patch admin_video_path(video), params: update_params
        expect(response).to redirect_to(admin_video_path(video))
      end
    end
  end

  describe "DELETE /admin/videos/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "deletes the video" do
        video
        expect {
          delete admin_video_path(video)
        }.to change(Video, :count).by(-1)
      end

      it "redirects to videos list" do
        delete admin_video_path(video)
        expect(response).to redirect_to(admin_videos_path)
      end
    end
  end

  describe "POST /admin/videos/:id/publish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:draft_video) { create(:video, author: admin_user, status: "draft") }

      it "publishes the video" do
        post publish_admin_video_path(draft_video)
        draft_video.reload
        expect(draft_video.status).to eq("published")
      end
    end
  end

  describe "POST /admin/videos/:id/unpublish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:published_video) { create(:video, author: admin_user, status: "published") }

      it "unpublishes the video" do
        post unpublish_admin_video_path(published_video)
        published_video.reload
        expect(published_video.status).to eq("draft")
      end
    end
  end
end
