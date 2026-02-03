# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendInvitationEmailWorker, type: :worker do
  let(:inviter) { create(:user) }
  let(:invitation) { create(:invitation, inviter: inviter, status: "pending") }

  describe "#perform" do
    it "logs invitation email" do
      expect(Rails.logger).to receive(:info).with(/Sending invitation email/)
      described_class.new.perform(invitation.id)
    end

    it "does nothing when invitation not found" do
      expect(Rails.logger).not_to receive(:info)
      described_class.new.perform(-1)
    end

    it "does nothing when invitation is not pending" do
      accepted_invitation = create(:invitation, inviter: inviter, status: "accepted")
      expect(Rails.logger).not_to receive(:info)
      described_class.new.perform(accepted_invitation.id)
    end
  end

  describe "sidekiq options" do
    it "uses mailers queue" do
      expect(described_class.sidekiq_options["queue"]).to eq(:mailers)
    end
  end
end
