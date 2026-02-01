# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    association :author, factory: :user
    sequence(:slug) { |n| "page-#{n}" }
    title_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    content_i18n { { 'en' => Faker::Lorem.paragraphs(number: 3).join("\n\n"), 'pl' => Faker::Lorem.paragraphs(number: 3).join("\n\n") } }
    meta_description_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    page_type { 'custom' }
    status { 'draft' }
    show_in_menu { false }
    menu_position { 0 }

    trait :published do
      status { 'published' }
      published_at { Time.current }
    end

    trait :in_menu do
      show_in_menu { true }
      sequence(:menu_position) { |n| n }
    end

    trait :about do
      page_type { 'about' }
      slug { 'about' }
    end

    trait :contact do
      page_type { 'contact' }
      slug { 'contact' }
    end

    trait :terms do
      page_type { 'terms' }
      slug { 'terms' }
    end

    trait :privacy do
      page_type { 'privacy' }
      slug { 'privacy' }
    end
  end
end
