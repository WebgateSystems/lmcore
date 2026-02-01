# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :user
    association :commentable, factory: :post
    content { Faker::Lorem.paragraph }
    status { 'pending' }

    trait :approved do
      status { 'approved' }
      approved_at { Time.current }
    end

    trait :spam do
      status { 'spam' }
    end

    trait :guest do
      user { nil }
      guest_name { Faker::Name.name }
      guest_email { Faker::Internet.email }
    end

    trait :reply do
      association :parent, factory: :comment
    end

    trait :on_video do
      association :commentable, factory: :video
    end

    trait :on_photo do
      association :commentable, factory: :photo
    end
  end
end
