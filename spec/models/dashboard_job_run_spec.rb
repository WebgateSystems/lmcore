# frozen_string_literal: true

require "rails_helper"

RSpec.describe DashboardJobRun do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:video).optional }
    it { is_expected.to belong_to(:post).optional }
  end

  describe "validations" do
    subject { build(:dashboard_job_run) }

    it { is_expected.to validate_presence_of(:job_type) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe ".recent_first" do
      it "orders by created_at desc" do
        older = create(:dashboard_job_run, user: user, created_at: 2.days.ago)
        newer = create(:dashboard_job_run, user: user, created_at: 1.day.ago)

        expect(described_class.recent_first.to_a).to eq([ newer, older ])
      end
    end

    describe ".for_user" do
      it "limits results to the given user" do
        own = create(:dashboard_job_run, user: user)
        create(:dashboard_job_run, user: other_user)

        expect(described_class.for_user(user)).to contain_exactly(own)
      end
    end

    describe ".youtube_sync" do
      it "returns only youtube_sync runs" do
        sync_run = create(:dashboard_job_run, user: user, job_type: "youtube_sync")
        create(:dashboard_job_run, user: user, job_type: "video_to_post")

        expect(described_class.youtube_sync).to contain_exactly(sync_run)
      end
    end

    describe ".video_to_post" do
      it "returns only video_to_post runs" do
        v2p_run = create(:dashboard_job_run, user: user, job_type: "video_to_post")
        create(:dashboard_job_run, user: user, job_type: "youtube_sync")

        expect(described_class.video_to_post).to contain_exactly(v2p_run)
      end
    end
  end

  describe "#mark_running!" do
    let(:run) { create(:dashboard_job_run, status: "queued") }

    it "updates status, stage and started_at" do
      run.mark_running!(stage: "fetch_video_ids")
      run.reload

      expect(run.status).to eq("running")
      expect(run.stage).to eq("fetch_video_ids")
      expect(run.started_at).to be_present
    end

    it "does not overwrite an existing started_at" do
      started = 1.hour.ago
      run.update!(started_at: started)

      run.mark_running!
      run.reload

      expect(run.started_at.to_i).to eq(started.to_i)
    end

    it "merges payload when provided" do
      run.mark_running!(payload: { "channel_url" => "https://example.com" })
      expect(run.reload.payload).to eq({ "channel_url" => "https://example.com" })
    end
  end

  describe "#mark_failed!" do
    let(:run) { create(:dashboard_job_run, status: "running") }

    it "marks the run as failed" do
      run.mark_failed!(error_message: "boom", stage: "metadata_fetch")
      run.reload

      expect(run.status).to eq("failed")
      expect(run.error_message).to eq("boom")
      expect(run.stage).to eq("metadata_fetch")
      expect(run.finished_at).to be_present
    end
  end

  describe "#mark_completed!" do
    let(:run) { create(:dashboard_job_run, status: "running", stage: "importing") }

    it "marks the run as completed and copies counters from stats" do
      stats = { processed: 10, created: 5, updated: 3, skipped: 1, errors: 1 }
      run.mark_completed!(stage: "finished", stats: stats, payload: { "total" => 10 })

      run.reload
      expect(run.status).to eq("completed")
      expect(run.stage).to eq("finished")
      expect(run.finished_at).to be_present
      expect(run.created_count).to eq(5)
      expect(run.updated_count).to eq(3)
      expect(run.skipped_count).to eq(1)
      expect(run.error_count).to eq(1)
      expect(run.progress_current).to eq(10)
      expect(run.payload).to eq({ "total" => 10 })
    end

    it "leaves counters untouched when stats not provided" do
      run.update!(created_count: 7)
      run.mark_completed!

      expect(run.reload.created_count).to eq(7)
    end
  end
end
