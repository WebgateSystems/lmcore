# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    sequence(:username) { |n| "user#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    status { 'active' }
    confirmed_at { Time.current }
    locale { 'en' }
    timezone { 'UTC' }

    trait :pending do
      status { 'pending' }
      confirmed_at { nil }
    end

    trait :suspended do
      status { 'suspended' }
    end

    trait :with_role do
      association :role
    end

    trait :admin do
      association :role, :admin
    end

    trait :super_admin do
      association :role, :super_admin
    end

    trait :author do
      association :role, :author
    end

    trait :with_plan do
      association :price_plan
    end

    trait :free_plan do
      association :price_plan, :free
    end

    trait :pro_plan do
      association :price_plan, :professional
    end

    trait :with_vanity_domain do
      sequence(:vanity_domain) { |n| "myblog#{n}.com" }
      vanity_domain_verified { true }
    end

    trait :with_bio do
      bio_i18n { { 'en' => Faker::Lorem.paragraph, 'pl' => Faker::Lorem.paragraph } }
    end
  end
end
