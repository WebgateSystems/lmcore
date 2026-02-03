# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    transient do
      role_name { nil }
    end

    sequence(:slug) { |n| "role-#{n}" }
    permissions { [] }
    priority { 0 }
    system_role { false }

    after(:build) do |role, evaluator|
      generated_name = evaluator.role_name || "Role #{role.slug}"
      role.write_attribute(:name, generated_name)
      role.name_i18n = { 'en' => generated_name, 'pl' => "Rola #{generated_name}" }
      role.description_i18n = { 'en' => 'Description', 'pl' => 'Opis' }
    end

    trait :super_admin do
      transient do
        role_name { 'Super Admin' }
      end
      slug { 'super-admin' }
      permissions { [ '*' ] }
      priority { 100 }
      system_role { true }
    end

    trait :admin do
      transient do
        role_name { 'Admin' }
      end
      slug { 'admin' }
      permissions { %w[manage_users manage_content manage_settings] }
      priority { 90 }
      system_role { true }
    end

    trait :moderator do
      transient do
        role_name { 'Moderator' }
      end
      slug { 'moderator' }
      permissions { %w[moderate_comments moderate_content] }
      priority { 50 }
      system_role { true }
    end

    trait :author do
      transient do
        role_name { 'Author' }
      end
      slug { 'author' }
      permissions { %w[create_content edit_own_content] }
      priority { 30 }
      system_role { true }
    end

    trait :user do
      transient do
        role_name { 'User' }
      end
      slug { 'user' }
      permissions { %w[comment react] }
      priority { 10 }
      system_role { true }
    end
  end
end
