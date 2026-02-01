# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}" }
    sequence(:slug) { |n| "tag-#{n}" }
    taggings_count { 0 }
  end
end
