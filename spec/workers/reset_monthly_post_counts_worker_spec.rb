# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResetMonthlyPostCountsWorker, type: :worker do
  describe "sidekiq options" do
    it "uses the low-priority queue (this is a monthly housekeeping job)" do
      expect(described_class.sidekiq_options["queue"]).to eq(:low)
    end
  end

  describe "#perform" do
    it "resets posts_this_month for every user to zero" do
      a = create(:user)
      b = create(:user)
      a.update_column(:posts_this_month, 5)
      b.update_column(:posts_this_month, 12)

      expect {
        described_class.new.perform
      }.to change { [ a.reload.posts_this_month, b.reload.posts_this_month ] }
        .from([ 5, 12 ]).to([ 0, 0 ])
    end

    it "logs that the reset happened (so ops can grep for it in production)" do
      expect(Rails.logger).to receive(:info).with(/Reset monthly post counts/)
      described_class.new.perform
    end
  end
end
