# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::PhotoPolicy, type: :policy do
  subject { described_class.new(user, photo) }

  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:photo) { create(:photo, author: admin_user) }

  context "when user is an admin" do
    let(:user) { admin_user }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:publish) }
    it { is_expected.to permit_action(:unpublish) }
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
    let(:scope) { Pundit.policy_scope!(user, [ :admin, Photo ]) }

    context "when user is an admin" do
      let(:user) { admin_user }

      it "returns all photos" do
        photo
        expect(scope).to include(photo)
      end
    end

    context "when user is not an admin" do
      let(:user) { regular_user }

      it "returns no photos" do
        photo
        expect(scope).to be_empty
      end
    end
  end
end
