# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::VideoPolicy, type: :policy do
  subject { described_class.new(user, video) }

  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:video) { create(:video, author: admin_user) }

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
    let(:scope) { Pundit.policy_scope!(user, [ :admin, Video ]) }

    context "when user is an admin" do
      let(:user) { admin_user }

      it "returns all videos" do
        video
        expect(scope).to include(video)
      end
    end

    context "when user is not an admin" do
      let(:user) { regular_user }

      it "returns no videos" do
        video
        expect(scope).to be_empty
      end
    end
  end
end
