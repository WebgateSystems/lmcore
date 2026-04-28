# frozen_string_literal: true

FactoryBot.define do
  factory :user_identity do
    association :user
    provider { "google_oauth2" }
    sequence(:uid) { |n| "oauth-uid-#{n}" }
    sequence(:email) { |n| "oauth#{n}@example.com" }
    data { {} }
  end
end
