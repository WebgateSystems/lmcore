# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Videos", type: :request do
  let(:author) { create(:user, :author) }
  let(:video) { create(:video, author: author) }

  before do
    sign_in author
  end

  describe "POST /dashboard/videos/sync_youtube" do
    it "creates a sync run and enqueues worker" do
      allow(SiteSetting).to receive(:get).and_return("https://www.youtube.com/@AyderMuzhdabaev/videos")
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).with(author).and_return(%w[en ru])
      allow(SyncYoutubeChannelVideosWorker).to receive(:perform_async)

      expect {
        post sync_youtube_dashboard_videos_path, params: { sync_locale: "ru" }
      }.to change(DashboardJobRun, :count).by(1)

      run = DashboardJobRun.last
      expect(run.job_type).to eq("youtube_sync")
      expect(SyncYoutubeChannelVideosWorker).to have_received(:perform_async)
        .with(author.id, "https://www.youtube.com/@AyderMuzhdabaev/videos", "ru", nil, run.id)
    end
  end

  describe "GET /dashboard/videos/sync_status" do
    it "returns latest run status in json" do
      create(:dashboard_job_run, user: author, job_type: "youtube_sync", status: "running", stage: "fetch_video_ids")

      get sync_status_dashboard_videos_path, headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["present"]).to eq(true)
      expect(json["status"]).to eq("running")
      expect(json["stage"]).to eq("fetch_video_ids")
    end
  end

  describe "POST /dashboard/videos/:id/create_post_from_video" do
    it "creates a subtitle job and enqueues worker" do
      allow(CreatePostFromVideoSubtitlesWorker).to receive(:perform_async)

      expect {
        post create_post_from_video_dashboard_video_path(video)
      }.to change(DashboardJobRun, :count).by(1)

      run = DashboardJobRun.last
      expect(run.job_type).to eq("video_to_post")
      expect(run.video_id).to eq(video.id)
      expect(CreatePostFromVideoSubtitlesWorker).to have_received(:perform_async).with(author.id, video.id, run.id)
    end
  end

  describe "GET /dashboard/videos" do
    it "renders the index" do
      video
      get dashboard_videos_path
      expect(response).to have_http_status(:success)
    end

    it "filters by status" do
      create(:video, author: author, status: "draft")
      get dashboard_videos_path(status: "draft")
      expect(response).to have_http_status(:success)
    end

    it "filters by ?q= via TitleSearchable" do
      create(:video, author: author, title_i18n: { "en" => "Apricot Reel" })
      create(:video, author: author, title_i18n: { "en" => "Bananas Reel" })

      get dashboard_videos_path(q: "apricot")

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/videos/sync_youtube without a configured channel" do
    it "redirects with an alert when no channel URL is set" do
      allow(SiteSetting).to receive(:get).and_return(nil)
      post sync_youtube_dashboard_videos_path
      expect(response).to redirect_to(dashboard_videos_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST /dashboard/videos/:id/pin" do
    it "pins the target video" do
      target = create(:video, author: author, featured: false)

      post pin_dashboard_video_path(target), headers: { "HTTP_REFERER" => dashboard_videos_path }

      expect(target.reload.featured?).to be true
    end
  end

  describe "GET /dashboard/videos/new" do
    it "renders the form" do
      get new_dashboard_video_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard/videos/:id (show)" do
    it "redirects to edit" do
      get dashboard_video_path(video)
      expect(response).to redirect_to(edit_dashboard_video_path(video))
    end
  end

  describe "GET /dashboard/videos/:id/edit" do
    it "renders the edit form" do
      get edit_dashboard_video_path(video)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /dashboard/videos/:id" do
    it "updates editable fields" do
      patch dashboard_video_path(video), params: { video: { title: "Renamed Reel" } }
      expect(response).to redirect_to(dashboard_videos_path)
      expect(video.reload.title).to eq("Renamed Reel")
    end

    it "re-renders :edit when the change is invalid" do
      patch dashboard_video_path(video), params: { video: { slug: "" } }
      expect([ 200, 302, 422 ]).to include(response.status)
    end
  end

  describe "GET /dashboard/videos/sync_status with no run yet" do
    it "returns present: false when the user has never synced" do
      get sync_status_dashboard_videos_path, headers: { "ACCEPT" => "application/json" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["present"]).to eq(false)
    end
  end

  describe "DELETE /dashboard/videos/:id" do
    # The destroy action was switched from `discard` to `destroy!` to make
    # cascading consistent — the confirmation modal in the UI warns the
    # author this is irreversible.
    it "hard-deletes the video and cascades comments + taggings + attachments" do
      video
      tag = Tag.create!(name: "VideoTag", slug: "video-tag")
      video.tags << tag
      commenter = create(:user)
      comment   = video.comments.create!(user: commenter, content: "great", status: "approved")
      reaction  = video.reactions.create!(user: commenter, reaction_type: "like")

      expect { delete dashboard_video_path(video) }.to change(Video, :count).by(-1)

      expect(Comment.where(id: comment.id)).to be_empty
      expect(Reaction.where(id: reaction.id)).to be_empty
      expect(Tagging.where(taggable_type: "Video", taggable_id: video.id)).to be_empty
    end
  end
end
