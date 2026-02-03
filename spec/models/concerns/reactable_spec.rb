# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reactable, type: :model do
  # Use Post as a model that includes Reactable
  let(:author) { create(:user) }
  let(:reactor) { create(:user) }
  let(:post_record) { create(:post, author: author) }

  describe "associations" do
    it "has many reactions" do
      expect(post_record).to respond_to(:reactions)
    end
  end

  describe "#react!" do
    it "creates a reaction" do
      expect {
        post_record.react!(reactor, "like")
      }.to change { post_record.reactions.count }.by(1)
    end

    it "returns the reaction" do
      reaction = post_record.react!(reactor, "like")
      expect(reaction).to be_a(Reaction)
      expect(reaction.reaction_type).to eq("like")
    end

    it "updates existing reaction type" do
      post_record.react!(reactor, "like")
      post_record.react!(reactor, "love")

      expect(post_record.reactions.count).to eq(1)
      expect(post_record.reactions.first.reaction_type).to eq("love")
    end
  end

  describe "#unreact!" do
    it "removes a reaction" do
      post_record.react!(reactor, "like")

      expect {
        post_record.unreact!(reactor)
      }.to change { post_record.reactions.count }.by(-1)
    end

    it "doesn't raise error when no reaction exists" do
      expect { post_record.unreact!(reactor) }.not_to raise_error
    end
  end

  describe "#reacted_by?" do
    before { post_record.react!(reactor, "like") }

    it "returns true when user has reacted" do
      expect(post_record.reacted_by?(reactor)).to be true
    end

    it "returns false when user hasn't reacted" do
      other_user = create(:user)
      expect(post_record.reacted_by?(other_user)).to be false
    end

    it "returns true for specific reaction type" do
      expect(post_record.reacted_by?(reactor, reaction_type: "like")).to be true
    end

    it "returns false for different reaction type" do
      expect(post_record.reacted_by?(reactor, reaction_type: "love")).to be false
    end
  end

  describe "#reactions_summary" do
    it "returns count grouped by reaction type" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      post_record.react!(user1, "like")
      post_record.react!(user2, "like")
      post_record.react!(user3, "love")

      summary = post_record.reactions_summary
      expect(summary["like"]).to eq(2)
      expect(summary["love"]).to eq(1)
    end

    it "returns empty hash when no reactions" do
      expect(post_record.reactions_summary).to eq({})
    end
  end
end
