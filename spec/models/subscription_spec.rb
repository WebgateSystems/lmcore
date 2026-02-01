# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription do
  describe 'validations' do
    subject { build(:subscription) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:started_at) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:price_plan) }
    it { is_expected.to have_many(:payments).dependent(:nullify) }
  end

  describe 'scopes' do
    it 'filters active subscriptions' do
      active = create(:subscription, status: 'active')
      cancelled = create(:subscription, :cancelled)
      expect(described_class.active).to include(active)
      expect(described_class.active).not_to include(cancelled)
    end

    it 'filters cancelled subscriptions' do
      cancelled = create(:subscription, :cancelled)
      expect(described_class.cancelled).to include(cancelled)
    end

    it 'filters expired subscriptions' do
      expired_sub = create(:subscription, status: 'expired', expires_at: 1.day.ago)
      expect(described_class.expired).to include(expired_sub)
    end

    it 'filters expiring soon subscriptions' do
      expiring_soon = create(:subscription, status: 'active', expires_at: 3.days.from_now)
      active = create(:subscription, status: 'active', expires_at: 1.month.from_now)
      expect(described_class.expiring_soon).to include(expiring_soon)
      expect(described_class.expiring_soon).not_to include(active)
    end
  end

  describe 'state machine' do
    it 'starts as active' do
      subscription = create(:subscription)
      expect(subscription.status).to eq('active')
    end

    it 'can be marked as past due' do
      subscription = create(:subscription)
      subscription.mark_past_due!
      expect(subscription.status).to eq('past_due')
    end

    it 'can be cancelled' do
      subscription = create(:subscription)
      subscription.cancel!
      expect(subscription.status).to eq('cancelled')
      expect(subscription.cancelled_at).to be_present
      expect(subscription.auto_renew).to be false
    end

    it 'can be expired' do
      subscription = create(:subscription)
      subscription.expire!
      expect(subscription.status).to eq('expired')
    end

    it 'can be reactivated from past_due' do
      subscription = create(:subscription)
      subscription.mark_past_due!
      subscription.reactivate!
      expect(subscription.status).to eq('active')
    end
  end

  describe '#days_remaining' do
    it 'calculates days until expiration' do
      subscription = build(:subscription, expires_at: 10.days.from_now)
      expect(subscription.days_remaining).to eq(10)
    end

    it 'returns 0 for expired subscriptions' do
      subscription = build(:subscription, expires_at: 1.day.ago)
      expect(subscription.days_remaining).to eq(0)
    end
  end

  describe '#truly_expired?' do
    it 'returns true when status is expired' do
      subscription = build(:subscription, status: 'expired')
      expect(subscription.truly_expired?).to be true
    end

    it 'returns true when expires_at is in the past' do
      subscription = build(:subscription, expires_at: 1.day.ago)
      expect(subscription.truly_expired?).to be true
    end
  end

  describe '#expired? (AASM)' do
    it 'returns true when status is expired' do
      subscription = build(:subscription, status: 'expired')
      expect(subscription.expired?).to be true
    end
  end

  describe '#trial?' do
    it 'returns true during trial period' do
      subscription = build(:subscription, trial_ends_at: 7.days.from_now)
      expect(subscription.trial?).to be true
    end

    it 'returns false after trial ends' do
      subscription = build(:subscription, trial_ends_at: 1.day.ago)
      expect(subscription.trial?).to be false
    end
  end

  describe '#renew!' do
    it 'updates expires_at and reactivates' do
      subscription = create(:subscription, status: 'cancelled', expires_at: 1.day.ago, cancelled_at: 2.days.ago)
      new_date = 1.month.from_now
      subscription.renew!(new_date)

      expect(subscription.expires_at).to eq(new_date)
      expect(subscription.status).to eq('active')
    end
  end

  describe '#upgrade_to' do
    it 'updates subscription and user plan' do
      subscription = create(:subscription)
      new_plan = create(:price_plan, slug: 'professional-test', price_cents: 5000)

      subscription.upgrade_to(new_plan)

      expect(subscription.price_plan).to eq(new_plan)
      expect(subscription.user.price_plan).to eq(new_plan)
    end
  end

  describe 'callbacks' do
    it 'updates user plan on create' do
      plan = create(:price_plan, slug: 'test-callback-plan')
      user = create(:user)
      expires = 1.month.from_now

      create(:subscription, user: user, price_plan: plan, expires_at: expires)

      expect(user.reload.price_plan).to eq(plan)
      expect(user.subscription_expires_at).to be_within(1.second).of(expires)
    end
  end
end
