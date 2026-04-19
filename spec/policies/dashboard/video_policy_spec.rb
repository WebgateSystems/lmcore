# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::VideoPolicy, type: :policy do
  subject(:policy) { described_class.new(user, video) }

  let(:owner) { create(:user, :author) }
  let(:other_author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:video) { create(:video, author: owner) }

  context "when user owns the video" do
    let(:user) { owner }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:sync_youtube) }
    it { is_expected.to permit_action(:create_post_from_video) }
  end

  context "when user is another author" do
    let(:user) { other_author }

    it { is_expected.to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.to permit_action(:sync_youtube) }
    it { is_expected.not_to permit_action(:create_post_from_video) }
  end

  context "when user is a moderator on someone else's video" do
    let(:user) { moderator }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:create_post_from_video) }
  end

  describe Dashboard::VideoPolicy::Scope do
    it "limits moderators to their own videos (dashboard is per-blog)" do
      moderator_video = create(:video, author: moderator)
      create(:video, author: owner)
      create(:video, author: other_author)

      scope = described_class.new(moderator, Video.all).resolve
      expect(scope).to contain_exactly(moderator_video)
    end
  end
end
