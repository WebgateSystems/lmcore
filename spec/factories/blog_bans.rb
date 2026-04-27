# frozen_string_literal: true

FactoryBot.define do
  factory :blog_ban do
    association :blog_owner, factory: :user
    association :user
    association :banned_by, factory: :user
    reason { "Violation of blog rules" }
    active { true }
    permanent { true }
  end
end
