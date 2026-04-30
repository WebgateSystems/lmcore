# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::SettingsPolicy, type: :policy do
  subject(:policy) { described_class.new(user, :settings) }

  context "when user is an author" do
    let(:user) { create(:user, :author) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
  end

  context "when user is a moderator" do
    let(:user) { create(:user, :moderator) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
  end

  context "when user is an active regular user" do
    let(:user) { create(:user) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
  end
end
