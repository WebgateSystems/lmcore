# frozen_string_literal: true

FactoryBot.define do
  factory :video do
    association :author, factory: :user
    sequence(:slug) { |n| "video-#{n}" }
    title_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    description_i18n { { 'en' => Faker::Lorem.paragraph, 'pl' => Faker::Lorem.paragraph } }
    status { 'draft' }
    featured { false }
    archived { false }
    comments_enabled { true }
    video_provider { 'youtube' }
    video_external_id { 'dQw4w9WgXcQ' }
    duration_seconds { 212 }

    trait :published do
      status { 'published' }
      published_at { 1.hour.ago }
    end

    trait :youtube do
      video_provider { 'youtube' }
      video_external_id { 'dQw4w9WgXcQ' }
    end

    trait :vimeo do
      video_provider { 'vimeo' }
      video_external_id { '123456789' }
    end

    trait :self_hosted do
      video_provider { 'self_hosted' }
      video_external_id { nil }
      video_url { 'https://example.com/video.mp4' }
    end

    trait :with_category do
      association :category
    end
  end
end
