# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::PostPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:owner) { create(:user, :author) }
  let(:other_author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:visitor) { create(:user) }
  let(:record) { create(:post, author: owner) }

  context "when user is the author" do
    let(:user) { owner }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:publish) }
  end

  context "when user is another author" do
    let(:user) { other_author }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is a moderator" do
    let(:user) { moderator }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:publish) }
  end

  context "when user has no dashboard role" do
    let(:user) { visitor }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:show) }
  end

  describe Dashboard::PostPolicy::Scope do
    it "limits to own posts for regular authors" do
      own_post = create(:post, author: owner)
      create(:post, author: other_author)

      scope = described_class.new(owner, Post.all).resolve
      expect(scope).to contain_exactly(own_post)
    end

    it "returns all kept posts for moderators" do
      post_a = create(:post, author: owner)
      post_b = create(:post, author: other_author)

      scope = described_class.new(moderator, Post.all).resolve
      expect(scope).to contain_exactly(post_a, post_b)
    end
  end
end
