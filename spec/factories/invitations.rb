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

    trait :for_blog do
      transient do
        blog_owner_user { nil }
      end

      blog_owner { blog_owner_user || association(:user, :author) }
      blog_role_slug { 'editor' }

      before(:create) do |_invitation, _evaluator|
        %w[editor moderator contributor].each do |slug|
          next if Role.exists?(slug: slug)
          priority = { 'moderator' => 50, 'editor' => 40, 'contributor' => 20 }.fetch(slug)
          role = Role.new(
            slug: slug,
            name_i18n: { 'en' => slug.capitalize },
            description_i18n: { 'en' => slug.capitalize },
            permissions: [],
            priority: priority,
            system_role: true
          )
          role.write_attribute(:name, slug.capitalize)
          role.save!
        end
      end
    end
  end
end
