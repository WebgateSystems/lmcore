# frozen_string_literal: true

require "rails_helper"

RSpec.describe VideoPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:author)        { create(:user, :author) }
  let(:other_author)  { create(:user, :author) }
  let(:admin)         { create(:user, :admin) }
  let(:record)        { create(:video, :published, author: author) }

  context "guest" do
    let(:user) { nil }

    it { is_expected.to permit_action(:index) }
    it "permits show on published+visible videos" do
      expect(policy.show?).to be true
    end
    it { is_expected.not_to permit_action(:create) }
  end

  context "owner" do
    let(:user) { author }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:publish) }
  end

  context "admin" do
    let(:user) { admin }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "stranger viewing a draft" do
    let(:user) { other_author }
    let(:record) { create(:video, author: author, status: "draft") }

    it "cannot see, update or destroy" do
      expect(policy.show?).to be false
      expect(policy.update?).to be false
      expect(policy.destroy?).to be false
    end
  end

  describe "#create?" do
    it "is false without a user" do
      expect(described_class.new(nil, Video.new).create?).to be false
    end

    it "is true if the user has the external_video feature" do
      allow(author).to receive(:has_feature?).and_return(false)
      allow(author).to receive(:has_feature?).with("external_video").and_return(true)
      expect(described_class.new(author, Video.new).create?).to be true
    end

    it "is true if the user has self_hosted_video feature" do
      allow(author).to receive(:has_feature?).and_return(false)
      allow(author).to receive(:has_feature?).with("self_hosted_video").and_return(true)
      expect(described_class.new(author, Video.new).create?).to be true
    end
  end

  describe "Scope" do
    let!(:published) { create(:video, :published, author: author) }
    let!(:draft)     { create(:video, author: author, status: "draft") }

    it "guests see only published+visible videos" do
      expect(VideoPolicy::Scope.new(nil, Video).resolve).to include(published)
      expect(VideoPolicy::Scope.new(nil, Video).resolve).not_to include(draft)
    end

    it "admins see everything" do
      expect(VideoPolicy::Scope.new(admin, Video).resolve).to include(published, draft)
    end

    it "the author sees their drafts plus other people's published" do
      other_published = create(:video, :published, author: other_author)
      results = VideoPolicy::Scope.new(author, Video).resolve
      expect(results).to include(published, draft, other_published)
    end
  end
end
