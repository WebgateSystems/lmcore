# frozen_string_literal: true

FactoryBot.define do
  factory :invitation do
    association :inviter, factory: :user
    sequence(:email) { |n| "invited#{n}@example.com" }
    token { SecureRandom.urlsafe_base64(32) }
    role_type { 'user' }
    status { 'pending' }
    expires_at { 7.days.from_now }

    trait :accepted do
      status { 'accepted' }
      accepted_at { Time.current }
      association :invitee, factory: :user
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :for_author do
      role_type { 'author' }
    end

    trait :for_admin do
      role_type { 'admin' }
    end
  end
end
