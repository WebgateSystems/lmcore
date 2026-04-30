# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::CategoryPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:owner) { create(:user, :author) }
  let(:other_author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:visitor) { create(:user) }
  let(:record) { create(:category, user: owner) }

  context "when user owns the category" do
    let(:user) { owner }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when user is another author" do
    let(:user) { other_author }

    it { is_expected.to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is a moderator on someone else's category" do
    let(:user) { moderator }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is an active regular user" do
    let(:user) { visitor }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
  end

  describe Dashboard::CategoryPolicy::Scope do
    it "limits categories to own for regular authors" do
      own = create(:category, user: owner)
      create(:category, user: other_author)

      scope = described_class.new(owner, Category.all).resolve
      expect(scope).to contain_exactly(own)
    end

    it "limits moderators to their own categories (dashboard is per-blog)" do
      moderator_cat = create(:category, user: moderator)
      create(:category, user: owner)
      create(:category, user: other_author)

      scope = described_class.new(moderator, Category.all).resolve
      expect(scope).to contain_exactly(moderator_cat)
    end
  end
end
