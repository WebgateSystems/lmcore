# frozen_string_literal: true

FactoryBot.define do
  factory :reaction do
    association :user
    association :reactable, factory: :post
    reaction_type { 'like' }

    Reaction::TYPES.each do |type|
      trait type.to_sym do
        reaction_type { type }
      end
    end

    trait :on_comment do
      association :reactable, factory: :comment
    end

    trait :on_video do
      association :reactable, factory: :video
    end
  end
end
