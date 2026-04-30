# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::TagPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:visitor) { create(:user) }
  let(:record) { create(:tag) }

  context "when user is an author" do
    let(:user) { author }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    # Tags are a global vocabulary -- mutations from /dashboard are blocked
    # for everyone (use /admin for the global tag dictionary).
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is a moderator" do
    let(:user) { moderator }

    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is an active regular user" do
    let(:user) { visitor }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
  end

  describe Dashboard::TagPolicy::Scope do
    it "returns only tags that the user has used on their own content" do
      mine_tag = create(:tag)
      other_tag = create(:tag)
      unused_tag = create(:tag)

      mine_post = create(:post, author: author)
      Tagging.create!(tag: mine_tag, taggable: mine_post)
      Tagging.create!(tag: other_tag, taggable: create(:post, author: create(:user, :author)))

      scope = described_class.new(author, Tag.all).resolve
      expect(scope).to include(mine_tag)
      expect(scope).not_to include(other_tag)
      expect(scope).not_to include(unused_tag)
    end

    it "returns nothing for visitors without dashboard role" do
      tag = create(:tag)
      Tagging.create!(tag: tag, taggable: create(:post, author: author))
      scope = described_class.new(visitor, Tag.all).resolve
      expect(scope).to be_empty
    end
  end
end
