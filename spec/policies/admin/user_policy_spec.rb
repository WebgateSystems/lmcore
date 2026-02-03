# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UserPolicy, type: :policy do
  subject { described_class.new(user, target_user) }

  let(:super_admin_user) { create(:user, :super_admin) }
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:target_user) { create(:user) }

  context "when user is a super admin" do
    let(:user) { super_admin_user }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:suspend) }
    it { is_expected.to permit_action(:activate) }
    it { is_expected.to permit_action(:impersonate) }
    it { is_expected.to permit_action(:change_role) }
  end

  context "when user is an admin" do
    let(:user) { admin_user }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:suspend) }
    it { is_expected.to permit_action(:activate) }
  end

  context "when user is not an admin" do
    let(:user) { regular_user }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:suspend) }
    it { is_expected.not_to permit_action(:activate) }
  end

  describe "Scope" do
    let(:scope) { Pundit.policy_scope!(user, [ :admin, User ]) }

    context "when user is an admin" do
      let(:user) { admin_user }

      it "returns all users" do
        target_user
        expect(scope).to include(target_user)
      end
    end

    context "when user is not an admin" do
      let(:user) { regular_user }

      it "returns no users" do
        target_user
        expect(scope).to be_empty
      end
    end
  end
end
