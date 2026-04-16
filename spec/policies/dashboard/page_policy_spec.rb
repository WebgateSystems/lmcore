# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::PagePolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:owner) { create(:user, :author) }
  let(:other_author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:record) { create(:page, author: owner) }

  context "when user is the author" do
    let(:user) { owner }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
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

  context "when user is a moderator" do
    let(:user) { moderator }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe Dashboard::PagePolicy::Scope do
    it "limits pages to own for regular authors" do
      own = create(:page, author: owner)
      create(:page, author: other_author)

      scope = described_class.new(owner, Page.all).resolve
      expect(scope).to contain_exactly(own)
    end
  end
end
