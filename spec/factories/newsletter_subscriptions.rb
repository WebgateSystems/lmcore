# frozen_string_literal: true

FactoryBot.define do
  factory :newsletter_subscription do
    association :blog_owner, factory: :user
    association :user
    email { user.email }
    status { "active" }
  end
end
