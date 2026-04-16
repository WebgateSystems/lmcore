# frozen_string_literal: true

require "rails_helper"

RSpec.describe SyncYoutubeChannelVideosWorker, type: :worker do
  let(:author) { create(:user, :author) }
  let(:channel_url) { "https://www.youtube.com/@example/videos" }

  describe "#perform" do
    it "does nothing when the user is missing" do
      expect(Youtube::ChannelVideosSyncService).not_to receive(:new)

      expect {
        described_class.new.perform(SecureRandom.uuid, channel_url)
      }.not_to raise_error
    end

    it "drives job run updates through progress callbacks and marks it completed" do
      run = create(:dashboard_job_run, user: author, job_type: "youtube_sync", status: "queued")
      service = instance_double(Youtube::ChannelVideosSyncService)

      allow(Youtube::ChannelVideosSyncService).to receive(:new) do |**kwargs|
        progress = kwargs[:progress]
        progress&.call(:start, user_id: author.id, channel_url: channel_url, download_thumbnails: false,
                               sleep_requests: 1.5, retry_limit: 5)
        progress&.call(:phase, name: "fetch_video_ids")
        progress&.call(:discovered, total: 3)
        progress&.call(:progress, index: 1, total: 3, percent: 33.3, video_id: "v1",
                                  result: :created, stats: { created: 1, updated: 0, skipped: 0, errors: 0 })
        progress&.call(:finish, stats: { processed: 3, created: 3, updated: 0, skipped: 0, errors: 0 })
        service
      end
      allow(service).to receive(:call).and_return(processed: 3, created: 3, updated: 0, skipped: 0, errors: 0)

      described_class.new.perform(author.id, channel_url, nil, nil, run.id)

      run.reload
      expect(run.status).to eq("completed")
      expect(run.stage).to eq("finished")
      expect(run.progress_total).to eq(3)
      expect(run.last_video_id).to eq("v1")
      expect(run.created_count).to eq(3)
    end

    it "marks the job run as failed and re-raises when the service raises" do
      run = create(:dashboard_job_run, user: author, job_type: "youtube_sync", status: "queued")
      allow(Youtube::ChannelVideosSyncService).to receive(:new).and_raise(StandardError, "kaboom")

      expect {
        described_class.new.perform(author.id, channel_url, nil, nil, run.id)
      }.to raise_error(StandardError, "kaboom")

      run.reload
      expect(run.status).to eq("failed")
      expect(run.stage).to eq("failed")
      expect(run.error_message).to eq("kaboom")
    end
  end
end
