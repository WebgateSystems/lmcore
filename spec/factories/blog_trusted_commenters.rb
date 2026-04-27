# frozen_string_literal: true

FactoryBot.define do
  factory :blog_trusted_commenter do
    association :blog_owner, factory: :user
    association :user
    association :granted_by, factory: :user
  end
end
