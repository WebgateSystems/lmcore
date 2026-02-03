# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::CategoryPolicy, type: :policy do
  subject { described_class.new(user, category) }

  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:category) { create(:category, user: admin_user) }

  context "when user is an admin" do
    let(:user) { admin_user }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when user is not an admin" do
    let(:user) { regular_user }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  describe "Scope" do
    let(:scope) { Pundit.policy_scope!(user, [ :admin, Category ]) }

    context "when user is an admin" do
      let(:user) { admin_user }

      it "returns all categories" do
        category
        expect(scope).to include(category)
      end
    end

    context "when user is not an admin" do
      let(:user) { regular_user }

      it "returns no categories" do
        category
        expect(scope).to be_empty
      end
    end
  end
end
