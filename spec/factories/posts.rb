# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    association :author, factory: :user
    sequence(:slug) { |n| "post-#{n}" }
    title_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    subtitle_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    lead_i18n { { 'en' => Faker::Lorem.paragraph, 'pl' => Faker::Lorem.paragraph } }
    content_i18n { { 'en' => Faker::Lorem.paragraphs(number: 5).join("\n\n"), 'pl' => Faker::Lorem.paragraphs(number: 5).join("\n\n") } }
    keywords_i18n { { 'en' => Faker::Lorem.words(number: 5).join(', '), 'pl' => Faker::Lorem.words(number: 5).join(', ') } }
    status { 'draft' }
    featured { false }
    archived { false }
    comments_enabled { true }

    trait :published do
      status { 'published' }
      published_at { 1.hour.ago }
    end

    trait :scheduled do
      status { 'scheduled' }
      scheduled_at { 1.day.from_now }
    end

    trait :archived do
      status { 'archived' }
      archived { true }
    end

    trait :featured do
      featured { true }
    end

    trait :with_category do
      association :category
    end

    trait :with_tags do
      after(:create) do |post|
        post.tag_list = Faker::Lorem.words(number: 3).join(', ')
        post.save!
      end
    end
  end
end
