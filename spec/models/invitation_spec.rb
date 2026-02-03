# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitation, type: :model do
  let(:inviter) { create(:user) }
  let(:invitation) { create(:invitation, inviter: inviter) }

  describe "associations" do
    it { is_expected.to belong_to(:inviter).class_name("User") }
    it { is_expected.to belong_to(:invitee).class_name("User").optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending accepted expired cancelled]) }

    it "generates token automatically" do
      new_invitation = create(:invitation, inviter: inviter)
      expect(new_invitation.token).to be_present
    end

    it "validates uniqueness of token at database level" do
      invitation
      # Create a duplicate directly bypassing callback
      duplicate = Invitation.new(inviter: inviter, email: "other@example.com", status: "pending", expires_at: 7.days.from_now)
      duplicate.token = invitation.token
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "scopes" do
    let!(:pending_invitation) { create(:invitation, inviter: inviter, status: "pending") }
    let!(:accepted_invitation) { create(:invitation, inviter: inviter, status: "accepted") }
    let!(:expired_invitation) { create(:invitation, inviter: inviter, status: "expired") }

    describe ".pending" do
      it "returns only pending invitations" do
        expect(described_class.pending).to include(pending_invitation)
        expect(described_class.pending).not_to include(accepted_invitation, expired_invitation)
      end
    end

    describe ".accepted" do
      it "returns only accepted invitations" do
        expect(described_class.accepted).to include(accepted_invitation)
      end
    end
  end

  describe "#accept!" do
    let(:invitee) { create(:user) }

    it "changes status to accepted" do
      invitation.accept!(invitee)
      expect(invitation.status).to eq("accepted")
      expect(invitation.invitee).to eq(invitee)
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      invitation.update_column(:expires_at, 1.day.ago)
      expect(invitation.expired?).to be true
    end

    it "returns false when expires_at is in the future" do
      expect(invitation.expired?).to be false
    end
  end
end
