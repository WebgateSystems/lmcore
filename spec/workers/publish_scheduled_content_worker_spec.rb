# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublishScheduledContentWorker, type: :worker do
  let(:author) { create(:user) }

  describe "#perform" do
    context "with posts" do
      let!(:scheduled_post) do
        post = create(:post, author: author, status: "scheduled")
        post.update_column(:scheduled_at, 1.hour.ago)
        post
      end

      let!(:future_post) do
        post = create(:post, author: author, status: "scheduled")
        post.update_column(:scheduled_at, 1.hour.from_now)
        post
      end

      let!(:draft_post) do
        create(:post, author: author, status: "draft")
      end

      it "publishes scheduled posts that are due" do
        described_class.new.perform

        scheduled_post.reload
        expect(scheduled_post.status).to eq("published")
      end

      it "does not publish future scheduled posts" do
        described_class.new.perform

        future_post.reload
        expect(future_post.status).to eq("scheduled")
      end

      it "does not affect draft posts" do
        described_class.new.perform

        draft_post.reload
        expect(draft_post.status).to eq("draft")
      end
    end

    context "with videos" do
      let!(:scheduled_video) do
        video = create(:video, author: author, status: "scheduled")
        video.update_column(:scheduled_at, 1.hour.ago)
        video
      end

      it "publishes scheduled videos that are due" do
        described_class.new.perform

        scheduled_video.reload
        expect(scheduled_video.status).to eq("published")
      end
    end
  end

  describe "sidekiq options" do
    it "uses critical queue" do
      expect(described_class.sidekiq_options["queue"]).to eq(:critical)
    end
  end
end
