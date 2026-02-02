# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    sequence(:name) { |n| "Partner #{n}" }
    sequence(:slug) { |n| "partner-#{n}" }
    url { Faker::Internet.url }
    icon_class { 'fa-brands fa-youtube' }
    locale { 'en' }
    position { 0 }
    active { true }
    description_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence, 'uk' => Faker::Lorem.sentence } }

    trait :inactive do
      active { false }
    end

    trait :polish do
      locale { 'pl' }
      name { 'Polski Partner' }
      description_i18n { { 'pl' => 'Opis partnera po polsku' } }
    end

    trait :ukrainian do
      locale { 'uk' }
      name { 'Український партнер' }
      description_i18n { { 'uk' => 'Опис партнера українською' } }
    end

    trait :english do
      locale { 'en' }
      name { 'English Partner' }
      description_i18n { { 'en' => 'Partner description in English' } }
    end

    trait :with_newspaper_icon do
      icon_class { 'fa-solid fa-newspaper' }
    end

    trait :with_microphone_icon do
      icon_class { 'fa-solid fa-microphone' }
    end

    trait :with_youtube_icon do
      icon_class { 'fa-brands fa-youtube' }
    end
  end
end
