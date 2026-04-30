# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::PartnerPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:visitor) { create(:user) }
  let(:record) { create(:partner, user: author) }

  context "when user is the author who owns the partner" do
    let(:user) { author }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:reorder) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when user is a moderator looking at someone else's partner" do
    let(:user) { moderator }

    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when user is an active regular user" do
    let(:user) { visitor }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:reorder) }
  end

  describe Dashboard::PartnerPolicy::Scope do
    it "limits partners to those owned by the user" do
      own = create(:partner, user: author)
      create(:partner, user: create(:user))

      scope = described_class.new(author, Partner.all).resolve
      expect(scope).to contain_exactly(own)
    end
  end
end
