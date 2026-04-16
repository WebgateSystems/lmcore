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
  end
end
