# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    association :user
    association :price_plan
    status { 'active' }
    payment_provider { 'stripe' }
    started_at { Time.current }
    expires_at { 1.month.from_now }
    auto_renew { true }

    trait :cancelled do
      status { 'cancelled' }
      cancelled_at { Time.current }
      auto_renew { false }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end

    trait :trial do
      trial_ends_at { 14.days.from_now }
    end

    trait :past_due do
      status { 'past_due' }
    end

    trait :yearly do
      expires_at { 1.year.from_now }
    end
  end
end
