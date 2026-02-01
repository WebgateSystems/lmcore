# frozen_string_literal: true

FactoryBot.define do
  factory :donation do
    association :donor, factory: :user
    association :recipient, factory: :user
    amount_cents { 500 }
    currency { 'EUR' }
    status { 'pending' }
    anonymous { false }
    recurring { false }

    trait :completed do
      status { 'completed' }
    end

    trait :anonymous do
      anonymous { true }
    end

    trait :recurring do
      recurring { true }
    end

    trait :guest do
      donor { nil }
      donor_name { Faker::Name.name }
      donor_email { Faker::Internet.email }
    end

    trait :with_message do
      message { Faker::Lorem.sentence }
    end
  end
end
