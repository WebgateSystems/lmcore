# frozen_string_literal: true

FactoryBot.define do
  factory :role_assignment do
    association :user
    association :role

    trait :with_scope do
      association :scope, factory: :user
    end

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :future_expiry do
      expires_at { 1.month.from_now }
    end
  end
end
