# frozen_string_literal: true

require "rails_helper"

RSpec.describe PostPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:author)        { create(:user, :author) }
  let(:other_author)  { create(:user, :author) }
  let(:admin)         { create(:user, :admin) }
  let(:record)        { create(:post, :published, author: author) }

  context "guest (no user)" do
    let(:user) { nil }
    let(:record) { create(:post, :published, author: author) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
  end

  context "owner" do
    let(:user) { author }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:publish) }
    it { is_expected.to permit_action(:archive) }
  end

  context "admin" do
    let(:user) { admin }

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:feature) }
  end

  context "stranger" do
    let(:user) { other_author }
    let(:record) { create(:post, author: author, status: "draft") }

    it "cannot see someone else's draft" do
      expect(policy.show?).to be false
    end

    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:feature) }
  end

  describe "#create?" do
    it "is true for an author with quota left" do
      expect(described_class.new(author, Post.new).create?).to be true
    end

    it "is false when there is no user" do
      expect(described_class.new(nil, Post.new).create?).to be false
    end
  end

  describe "#publish?" do
    it "is false without a user" do
      expect(described_class.new(nil, record).publish?).to be false
    end

    it "is true for the owner" do
      expect(described_class.new(author, record).publish?).to be true
    end
  end

  describe "Scope" do
    let!(:published) { create(:post, :published, author: author) }
    let!(:draft)     { create(:post, author: author, status: "draft") }
    let!(:other_published) { create(:post, :published, author: other_author) }

    it "shows published+visible posts to guests" do
      expect(PostPolicy::Scope.new(nil, Post).resolve).to contain_exactly(published, other_published)
    end

    it "lets admins see everything" do
      expect(PostPolicy::Scope.new(admin, Post).resolve).to include(published, draft, other_published)
    end

    it "lets a logged-in user see published + their own drafts" do
      results = PostPolicy::Scope.new(author, Post).resolve
      expect(results).to include(published, draft, other_published)
    end
  end
end
