# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateNotificationWorker, type: :worker do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }

  describe "#perform" do
    it "creates a notification for the user" do
      expect {
        described_class.new.perform(user.id, "new_comment")
      }.to change(Notification, :count).by(1)
    end

    it "creates notification with notifiable" do
      described_class.new.perform(user.id, "new_comment", "Post", post_record.id)

      notification = Notification.last
      expect(notification.notifiable).to eq(post_record)
    end

    it "does nothing when user not found" do
      expect {
        described_class.new.perform(-1, "new_comment")
      }.not_to change(Notification, :count)
    end

    it "creates notification with correct type" do
      described_class.new.perform(user.id, "new_follower")

      notification = Notification.last
      expect(notification.notification_type).to eq("new_follower")
    end

    it "passes data to notification" do
      described_class.new.perform(user.id, "test", nil, nil, { "key" => "value" })

      notification = Notification.last
      expect(notification.data["key"]).to eq("value")
    end

    it "handles missing notifiable gracefully" do
      expect {
        described_class.new.perform(user.id, "test", "Post", -1)
      }.to change(Notification, :count).by(1)

      notification = Notification.last
      expect(notification.notifiable).to be_nil
    end
  end

  describe "sidekiq options" do
    it "uses default queue" do
      expect(described_class.sidekiq_options["queue"]).to eq(:default)
    end
  end
end
