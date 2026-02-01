# frozen_string_literal: true

FactoryBot.define do
  factory :follow do
    association :follower, factory: :user
    association :followed, factory: :user
    status { 'active' }
    notify_posts { true }
    notify_videos { true }

    trait :muted do
      status { 'muted' }
    end

    trait :blocked do
      status { 'blocked' }
    end
  end
end
