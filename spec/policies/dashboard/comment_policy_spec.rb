# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::CommentPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:record) { create(:comment) }

  context "when user is only an author" do
    let(:user) { author }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is a moderator" do
    let(:user) { moderator }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe Dashboard::CommentPolicy::Scope do
    it "returns none for regular authors" do
      create(:comment)
      scope = described_class.new(author, Comment.all).resolve
      expect(scope).to be_empty
    end

    it "returns all comments for moderators" do
      c = create(:comment)
      scope = described_class.new(moderator, Comment.all).resolve
      expect(scope).to include(c)
    end
  end
end
