# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :user
    notification_type { 'system' }
    data { {} }

    trait :read do
      read_at { Time.current }
    end

    trait :sent do
      sent_at { Time.current }
      delivery_method { 'email' }
    end

    trait :new_comment do
      notification_type { 'new_comment' }
      association :actor, factory: :user
      association :notifiable, factory: :comment
    end

    trait :new_follower do
      notification_type { 'new_follower' }
      association :actor, factory: :user
    end

    trait :new_donation do
      notification_type { 'new_donation' }
      association :notifiable, factory: :donation
    end
  end
end
