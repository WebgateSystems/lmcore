# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    sequence(:name) { |n| "Theme #{n}" }
    sequence(:slug) { |n| "theme-#{n}" }
    description { Faker::Lorem.paragraph }
    author { Faker::Name.name }
    version { '1.0.0' }
    status { 'active' }
    is_system { false }
    is_premium { false }
    price_cents { 0 }
    config { {} }
    color_scheme { { 'primary' => '#007bff', 'secondary' => '#6c757d' } }

    trait :default do
      status { 'default' }
      is_system { true }
    end

    trait :system do
      is_system { true }
    end

    trait :premium do
      is_premium { true }
      price_cents { 2999 }
    end

    trait :inactive do
      status { 'inactive' }
    end
  end
end
