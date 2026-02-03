# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    sequence(:username) { |n| "user#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    status { 'active' }
    confirmed_at { Time.current }
    locale { 'en' }
    timezone { 'UTC' }

    trait :pending do
      status { 'pending' }
      confirmed_at { nil }
    end

    trait :suspended do
      status { 'suspended' }
    end

    trait :with_role do
      transient do
        role_trait { nil }
      end

      after(:create) do |user, evaluator|
        role = create(:role, evaluator.role_trait) if evaluator.role_trait
        create(:role_assignment, user: user, role: role) if role
      end
    end

    trait :admin do
      after(:create) do |user|
        admin_role = Role.find_by(slug: "admin")
        unless admin_role
          admin_role = Role.new(
            slug: "admin",
            name_i18n: { 'en' => 'Admin', 'pl' => 'Administrator' },
            description_i18n: { 'en' => 'Administrator', 'pl' => 'Administrator' },
            permissions: %w[manage_users manage_content manage_settings],
            priority: 90,
            system_role: true
          )
          admin_role.write_attribute(:name, "Admin")
          admin_role.save!
        end
        create(:role_assignment, user: user, role: admin_role)
      end
    end

    trait :super_admin do
      after(:create) do |user|
        super_admin_role = Role.find_by(slug: "super-admin")
        unless super_admin_role
          super_admin_role = Role.new(
            slug: "super-admin",
            name_i18n: { 'en' => 'Super Admin', 'pl' => 'Super Administrator' },
            description_i18n: { 'en' => 'Super Administrator', 'pl' => 'Super Administrator' },
            permissions: [ '*' ],
            priority: 100,
            system_role: true
          )
          super_admin_role.write_attribute(:name, "Super Admin")
          super_admin_role.save!
        end
        create(:role_assignment, user: user, role: super_admin_role)
      end
    end

    trait :moderator do
      after(:create) do |user|
        moderator_role = Role.find_by(slug: "moderator")
        unless moderator_role
          moderator_role = Role.new(
            slug: "moderator",
            name_i18n: { 'en' => 'Moderator', 'pl' => 'Moderator' },
            description_i18n: { 'en' => 'Moderator', 'pl' => 'Moderator' },
            permissions: %w[moderate_comments moderate_content],
            priority: 50,
            system_role: true
          )
          moderator_role.write_attribute(:name, "Moderator")
          moderator_role.save!
        end
        create(:role_assignment, user: user, role: moderator_role)
      end
    end

    trait :author do
      after(:create) do |user|
        author_role = Role.find_by(slug: "author")
        unless author_role
          author_role = Role.new(
            slug: "author",
            name_i18n: { 'en' => 'Author', 'pl' => 'Autor' },
            description_i18n: { 'en' => 'Author', 'pl' => 'Autor' },
            permissions: %w[create_content edit_own_content],
            priority: 30,
            system_role: true
          )
          author_role.write_attribute(:name, "Author")
          author_role.save!
        end
        create(:role_assignment, user: user, role: author_role)
      end
    end

    trait :with_plan do
      association :price_plan
    end

    trait :free_plan do
      association :price_plan, :free
    end

    trait :pro_plan do
      association :price_plan, :professional
    end

    trait :with_vanity_domain do
      sequence(:vanity_domain) { |n| "myblog#{n}.com" }
      vanity_domain_verified { true }
    end

    trait :with_bio do
      bio_i18n { { 'en' => Faker::Lorem.paragraph, 'pl' => Faker::Lorem.paragraph } }
    end
  end
end
