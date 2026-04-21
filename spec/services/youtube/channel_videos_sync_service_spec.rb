# frozen_string_literal: true

require "rails_helper"

RSpec.describe Youtube::ChannelVideosSyncService, type: :service do
  let(:author) { create(:user, :author, locale: "en") }
  let(:channel_url) { "https://www.youtube.com/@example/videos" }
  let(:service) do
    described_class.new(
      user: author,
      channel_url: channel_url,
      progress: nil,
      download_thumbnails: false,
      retry_limit: 1,
      retry_base_delay: 0,
      sleep_requests: 0
    )
  end
  let(:ok_status) { instance_double(Process::Status, success?: true) }

  before do
    allow(service).to receive(:ensure_yt_dlp_available!)
    allow(service).to receive(:backfill_missing_thumbnails)
    allow(service).to receive(:sleep)
  end

  describe "channel URL normalization" do
    it "normalizes bare hostnames to https and appends /videos" do
      instance = described_class.new(user: author, channel_url: "youtube.com/@foo")
      expect(instance.channel_url).to eq("https://youtube.com/@foo/videos")
    end

    it "keeps already normalized urls untouched" do
      instance = described_class.new(user: author, channel_url: "https://youtube.com/@bar/videos")
      expect(instance.channel_url).to eq("https://youtube.com/@bar/videos")
    end
  end

  describe "#call" do
    let(:entry) do
      {
        "id" => "abc123",
        "title" => "Example video",
        "description" => "Description body",
        "language" => "ru",
        "upload_date" => "20240301",
        "thumbnails" => [ { "url" => "https://img/x.jpg", "width" => 640, "height" => 360 } ],
        "view_count" => 100,
        "duration" => 200
      }
    end

    it "creates a new video from fetched metadata" do
      allow(service).to receive(:fetch_video_ids).and_return([ "abc123" ])
      allow(service).to receive(:fetch_video_metadata).and_return(entry)

      expect { service.call }.to change(Video, :count).by(1)

      video = Video.order(:created_at).last
      expect(video.author).to eq(author)
      expect(video.video_external_id).to eq("abc123")
      expect(video.video_provider).to eq("youtube")
      expect(video.status).to eq("published")
      expect(video.title_i18n).to include("ru" => "Example video")
      expect(video.video_data.dig("youtube", "id")).to eq("abc123")
    end

    it "falls back to configured service locale when yt-dlp language is missing" do
      allow(service).to receive(:fetch_video_ids).and_return([ "abc123" ])
      allow(service).to receive(:fetch_video_metadata).and_return(entry.except("language"))

      service.call

      video = Video.order(:created_at).last
      expect(video.title_i18n).to include("en" => "Example video")
    end

    it "skips ids already present for the user" do
      Video.create!(
        author: author,
        slug: "existing",
        title_i18n: { "en" => "existing" },
        status: "published",
        video_provider: "youtube",
        video_external_id: "abc123",
        external_source: "youtube",
        external_id: "abc123"
      )
      allow(service).to receive(:fetch_video_ids).and_return([ "abc123" ])
      allow(service).to receive(:fetch_video_metadata)

      stats = service.call
      expect(service).not_to have_received(:fetch_video_metadata)
      expect(stats[:skipped]).to eq(1)
      expect(stats[:processed]).to eq(0)
    end

    it "records an error when metadata fetching fails unrecoverably" do
      allow(service).to receive(:fetch_video_ids).and_return([ "abc123" ])
      allow(service).to receive(:fetch_video_metadata).and_raise("boom")

      stats = service.call
      expect(stats[:errors]).to be >= 1
      expect(stats[:processed]).to be >= 1
      expect(Video.count).to eq(0)
    end

    it "treats age-restricted metadata errors as skipped" do
      allow(service).to receive(:fetch_video_ids).and_return([ "abc123" ])
      allow(service).to receive(:fetch_video_metadata)
        .and_raise("Sign in to confirm your age")

      stats = service.call
      expect(stats[:skipped]).to eq(1)
      expect(stats[:errors]).to eq(0)
    end
  end

  describe "#call from a source file" do
    it "reads JSON array payloads and upserts videos" do
      file = Tempfile.new([ "yt", ".json" ])
      file.write(JSON.generate([
                                 {
                                   "id" => "from-file",
                                   "title" => "File video",
                                   "description" => "",
                                   "upload_date" => "20240101",
                                   "thumbnails" => []
                                 }
                               ]))
      file.flush

      instance = described_class.new(user: author, channel_url: channel_url,
                                     source_json_path: file.path,
                                     retry_base_delay: 0, sleep_requests: 0)
      allow(instance).to receive(:ensure_yt_dlp_available!)
      allow(instance).to receive(:backfill_missing_thumbnails)

      expect { instance.call }.to change(Video, :count).by(1)
      expect(Video.last.video_external_id).to eq("from-file")
    ensure
      file&.close
      file&.unlink
    end
  end
end
