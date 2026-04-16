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
      allow(SyncYoutubeChannelVideosWorker).to receive(:perform_async)

      expect {
        post sync_youtube_dashboard_videos_path
      }.to change(DashboardJobRun, :count).by(1)

      run = DashboardJobRun.last
      expect(run.job_type).to eq("youtube_sync")
      expect(SyncYoutubeChannelVideosWorker).to have_received(:perform_async)
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
end
