# frozen_string_literal: true

FactoryBot.define do
  factory :album do
    association :author, factory: :user
    sequence(:slug) { |n| "album-#{n}" }
    title_i18n { { "en" => Faker::Lorem.sentence, "pl" => Faker::Lorem.sentence } }
    description_i18n { { "en" => Faker::Lorem.paragraph, "pl" => Faker::Lorem.paragraph } }
    status { "draft" }
    featured { false }
    archived { false }
    comments_enabled { true }

    trait :published do
      status { "published" }
      published_at { 1.hour.ago }
    end
  end
end
