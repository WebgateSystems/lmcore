# frozen_string_literal: true

FactoryBot.define do
  factory :user_group do
    association :owner, factory: :user
    sequence(:name) { |n| "Group #{n}" }
    sequence(:slug) { |n| "group-#{n}" }
    description_i18n { { 'en' => Faker::Lorem.paragraph } }
    visibility { 'private' }

    trait :public do
      visibility { 'public' }
    end

    trait :with_members do
      after(:create) do |group|
        3.times { group.add_member(create(:user)) }
      end
    end
  end
end
