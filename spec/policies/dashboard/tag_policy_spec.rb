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
    it { is_expected.to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is a moderator" do
    let(:user) { moderator }

    it { is_expected.to permit_action(:destroy) }
  end

  context "when user has no dashboard role" do
    let(:user) { visitor }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
  end

  describe Dashboard::TagPolicy::Scope do
    it "returns all tags for dashboard users" do
      create(:tag)
      create(:tag)

      scope = described_class.new(author, Tag.all).resolve
      expect(scope.count).to eq(Tag.count)
    end
  end
end
