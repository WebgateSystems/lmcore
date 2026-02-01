# frozen_string_literal: true

FactoryBot.define do
  factory :photo do
    association :author, factory: :user
    sequence(:slug) { |n| "photo-#{n}" }
    title_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    description_i18n { { 'en' => Faker::Lorem.paragraph, 'pl' => Faker::Lorem.paragraph } }
    alt_text_i18n { { 'en' => Faker::Lorem.sentence, 'pl' => Faker::Lorem.sentence } }
    status { 'draft' }
    featured { false }
    archived { false }
    comments_enabled { true }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/test_image.jpg'), 'image/jpeg') }

    trait :published do
      status { 'published' }
      published_at { 1.hour.ago }
    end

    trait :with_category do
      association :category
    end

    trait :with_exif do
      exif_data do
        {
          'make' => 'Canon',
          'model' => 'EOS 5D Mark IV',
          'focal_length' => '50mm',
          'aperture' => 'f/2.8',
          'shutter_speed' => '1/250',
          'iso' => 400
        }
      end
    end
  end
end
