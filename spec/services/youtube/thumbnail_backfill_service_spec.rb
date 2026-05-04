# frozen_string_literal: true

require "rails_helper"

RSpec.describe Youtube::ThumbnailBackfillService, type: :service do
  let(:author) { create(:user, :author) }

  def build_video(youtube_thumbnails: [], external_thumbnail: nil)
    create(
      :video,
      author: author,
      video_data: {
        "youtube" => {
          "thumbnail" => external_thumbnail,
          "thumbnails" => youtube_thumbnails
        }
      }
    )
  end

  describe "#call" do
    it "returns zero when scope is empty" do
      stats = described_class.new(scope: Video.none).call(return_stats: true)
      expect(stats).to include(total: 0, processed: 0, updated: 0)
    end

    it "attaches a thumbnail from the first reachable candidate" do
      video = build_video(youtube_thumbnails: [ { "url" => "https://img.example.com/thumb.jpg" } ])
      service = described_class.new(scope: Video.where(id: video.id))

      allow(service).to receive(:assign_thumbnail_from_url).and_return(true)

      expect(service.call).to eq(1)
    end

    it "skips videos that already have a thumbnail" do
      video = build_video(youtube_thumbnails: [ { "url" => "https://img.example.com/thumb.jpg" } ])
      allow_any_instance_of(Video).to receive(:thumbnail).and_return(double(present?: true))
      allow_any_instance_of(Video).to receive(:thumbnail_file_available?).and_return(true)
      service = described_class.new(scope: Video.where(id: video.id))

      stats = service.call(return_stats: true)
      expect(stats[:skipped]).to eq(1)
      expect(stats[:updated]).to eq(0)
    end

    it "backfills videos whose thumbnail column points at a missing file" do
      video = build_video(youtube_thumbnails: [ { "url" => "https://img.example.com/thumb.jpg" } ])
      video.update_column(:thumbnail, "missing.jpg")
      service = described_class.new(scope: Video.where(id: video.id))

      allow(service).to receive(:assign_thumbnail_from_url).and_return(true)

      expect(service.call).to eq(1)
    end

    it "falls back to deterministic YouTube thumbnail URLs" do
      video = build_video(youtube_thumbnails: [])
      service = described_class.new(scope: Video.where(id: video.id))

      expect(service.send(:thumbnail_candidates_for, video)).to include(
        "https://i.ytimg.com/vi/#{video.video_external_id}/maxresdefault.jpg",
        "https://i.ytimg.com/vi/#{video.video_external_id}/hqdefault.jpg"
      )
    end

    it "respects stop_requested between iterations" do
      v1 = build_video(youtube_thumbnails: [ { "url" => "https://img.example.com/a.jpg" } ])
      v2 = build_video(youtube_thumbnails: [ { "url" => "https://img.example.com/b.jpg" } ])
      stop = ->(*) { true }
      service = described_class.new(scope: Video.where(id: [ v1.id, v2.id ]), stop_requested: stop)

      allow(service).to receive(:ensure_thumbnail_present)

      stats = service.call(return_stats: true)
      expect(stats[:processed]).to eq(0)
    end
  end
end
