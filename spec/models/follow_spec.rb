# frozen_string_literal: true

require "rails_helper"

RSpec.describe Follow, type: :model do
  let(:follower) { create(:user) }
  let(:followed) { create(:user) }
  let(:follow) { create(:follow, follower: follower, followed: followed) }

  describe "associations" do
    it { is_expected.to belong_to(:follower).class_name("User") }
    it { is_expected.to belong_to(:followed).class_name("User") }
  end

  describe "validations" do
    it "validates uniqueness of follower_id scoped to followed_id" do
      follow
      duplicate = build(:follow, follower: follower, followed: followed)
      expect(duplicate).not_to be_valid
    end

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[active muted blocked]) }

    it "validates that follower cannot follow themselves" do
      self_follow = build(:follow, follower: follower, followed: follower)
      expect(self_follow).not_to be_valid
      expect(self_follow.errors[:follower]).to include("can't follow yourself")
    end
  end

  describe "scopes" do
    let!(:active_follow) { create(:follow, follower: create(:user), followed: create(:user), status: "active") }
    let!(:muted_follow) { create(:follow, follower: create(:user), followed: create(:user), status: "muted") }
    let!(:blocked_follow) { create(:follow, follower: create(:user), followed: create(:user), status: "blocked") }

    describe ".active" do
      it "returns only active follows" do
        expect(described_class.active).to include(active_follow)
        expect(described_class.active).not_to include(muted_follow, blocked_follow)
      end
    end

    describe ".muted" do
      it "returns only muted follows" do
        expect(described_class.muted).to include(muted_follow)
        expect(described_class.muted).not_to include(active_follow, blocked_follow)
      end
    end

    describe ".blocked" do
      it "returns only blocked follows" do
        expect(described_class.blocked).to include(blocked_follow)
        expect(described_class.blocked).not_to include(active_follow, muted_follow)
      end
    end
  end

  describe "#mute!" do
    it "changes status to muted" do
      follow.mute!
      expect(follow.status).to eq("muted")
    end
  end

  describe "#unmute!" do
    it "changes status to active" do
      follow.update!(status: "muted")
      follow.unmute!
      expect(follow.status).to eq("active")
    end
  end

  describe "#block!" do
    it "changes status to blocked" do
      follow.block!
      expect(follow.status).to eq("blocked")
    end
  end

  describe "#unblock!" do
    it "changes status to active" do
      follow.update!(status: "blocked")
      follow.unblock!
      expect(follow.status).to eq("active")
    end
  end

  describe "status predicates" do
    it "#active? returns true when status is active" do
      follow.update!(status: "active")
      expect(follow.active?).to be true
      expect(follow.muted?).to be false
      expect(follow.blocked?).to be false
    end

    it "#muted? returns true when status is muted" do
      follow.update!(status: "muted")
      expect(follow.muted?).to be true
    end

    it "#blocked? returns true when status is blocked" do
      follow.update!(status: "blocked")
      expect(follow.blocked?).to be true
    end
  end
end
