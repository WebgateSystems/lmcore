# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    association :user
    sequence(:name) { |n| "API Key #{n}" }
    scopes { [] }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :with_scopes do
      scopes { %w[read write] }
    end

    trait :full_access do
      scopes { [ '*' ] }
    end
  end
end
