# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Follow do
  describe 'validations' do
    subject { create(:follow) }

    it { is_expected.to validate_uniqueness_of(:follower_id).scoped_to(:followed_id).ignoring_case_sensitivity }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[active muted blocked]) }

    it 'validates cannot follow self' do
      user = create(:user)
      follow = build(:follow, follower: user, followed: user)
      expect(follow).not_to be_valid
      expect(follow.errors[:follower]).to be_present
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:follower).class_name('User') }
    it { is_expected.to belong_to(:followed).class_name('User') }
  end

  describe 'scopes' do
    let!(:active_follow) { create(:follow, status: 'active') }
    let!(:muted_follow) { create(:follow, :muted) }
    let!(:blocked_follow) { create(:follow, :blocked) }

    it 'filters active follows' do
      expect(described_class.active).to include(active_follow)
      expect(described_class.active).not_to include(muted_follow)
    end

    it 'filters muted follows' do
      expect(described_class.muted).to include(muted_follow)
    end

    it 'filters blocked follows' do
      expect(described_class.blocked).to include(blocked_follow)
    end
  end

  describe 'status management' do
    let(:follow) { create(:follow) }

    it 'mutes the follow' do
      follow.mute!
      expect(follow.muted?).to be true
    end

    it 'unmutes the follow' do
      follow.mute!
      follow.unmute!
      expect(follow.active?).to be true
    end

    it 'blocks the follow' do
      follow.block!
      expect(follow.blocked?).to be true
    end

    it 'unblocks the follow' do
      follow.block!
      follow.unblock!
      expect(follow.active?).to be true
    end
  end

  describe 'status predicates' do
    it 'returns true for active' do
      follow = build(:follow, status: 'active')
      expect(follow.active?).to be true
    end

    it 'returns true for muted' do
      follow = build(:follow, status: 'muted')
      expect(follow.muted?).to be true
    end

    it 'returns true for blocked' do
      follow = build(:follow, status: 'blocked')
      expect(follow.blocked?).to be true
    end
  end
end
