# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :user
    payment_provider { 'stripe' }
    payment_type { 'subscription' }
    amount_cents { 1000 }
    currency { 'EUR' }
    status { 'pending' }

    trait :completed do
      status { 'completed' }
      paid_at { Time.current }
      net_amount_cents { 970 }
      fee_cents { 30 }
    end

    trait :failed do
      status { 'failed' }
      failure_reason { 'Card declined' }
    end

    trait :refunded do
      status { 'refunded' }
      paid_at { 1.week.ago }
      refunded_at { Time.current }
    end

    trait :donation do
      payment_type { 'donation' }
    end

    trait :theme_purchase do
      payment_type { 'theme_purchase' }
    end
  end
end
