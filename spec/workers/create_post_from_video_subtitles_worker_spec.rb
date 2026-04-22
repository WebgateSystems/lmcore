# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreatePostFromVideoSubtitlesWorker, type: :worker do
  let(:author) { create(:user, :author) }
  let(:video) { create(:video, author: author) }

  describe "#perform" do
    it "marks dashboard run as completed" do
      run = create(:dashboard_job_run, user: author, job_type: "video_to_post", status: "queued", video: video)
      post = create(:post, author: author, video: video)
      service_result = { result: :created, post: post }
      service = instance_double(Youtube::CreatePostFromVideoSubtitlesService, call: service_result)

      allow(Youtube::CreatePostFromVideoSubtitlesService).to receive(:new).and_return(service)

      described_class.new.perform(author.id, video.id, run.id)

      run.reload
      expect(run.status).to eq("completed")
      expect(run.post_id).to eq(post.id)
      expect(run.created_count).to eq(1)
      expect(run.stage).to eq("finished")
    end

    it "marks skipped result when service skips post creation" do
      run = create(:dashboard_job_run, user: author, job_type: "video_to_post", status: "queued", video: video)
      service_result = { result: :skipped, post: nil }
      service = instance_double(Youtube::CreatePostFromVideoSubtitlesService, call: service_result)
      allow(Youtube::CreatePostFromVideoSubtitlesService).to receive(:new).and_return(service)

      described_class.new.perform(author.id, video.id, run.id)

      run.reload
      expect(run.status).to eq("completed")
      expect(run.skipped_count).to eq(1)
      expect(run.post_id).to be_nil
    end

    it "returns early when user or video cannot be found" do
      expect(Youtube::CreatePostFromVideoSubtitlesService).not_to receive(:new)
      described_class.new.perform(SecureRandom.uuid, SecureRandom.uuid)
    end

    it "marks dashboard run as failed and re-raises errors" do
      run = create(:dashboard_job_run, user: author, job_type: "video_to_post", status: "queued", video: video)
      service = instance_double(Youtube::CreatePostFromVideoSubtitlesService)
      allow(service).to receive(:call).and_raise(StandardError, "boom")
      allow(Youtube::CreatePostFromVideoSubtitlesService).to receive(:new).and_return(service)

      expect {
        described_class.new.perform(author.id, video.id, run.id)
      }.to raise_error(StandardError, "boom")

      run.reload
      expect(run.status).to eq("failed")
      expect(run.error_message).to eq("boom")
    end
  end
end
