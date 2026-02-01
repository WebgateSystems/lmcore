# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    association :user
    sequence(:slug) { |n| "category-#{n}" }
    name_i18n { { 'en' => Faker::Lorem.word.capitalize, 'pl' => Faker::Lorem.word.capitalize } }
    description_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    category_type { 'general' }
    position { 0 }

    trait :for_posts do
      category_type { 'posts' }
    end

    trait :for_videos do
      category_type { 'videos' }
    end

    trait :for_photos do
      category_type { 'photos' }
    end

    trait :with_parent do
      association :parent, factory: :category
    end
  end
end
