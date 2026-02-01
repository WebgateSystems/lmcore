# frozen_string_literal: true

FactoryBot.define do
  factory :price_plan do
    transient do
      plan_name { nil }
    end

    sequence(:slug) { |n| "plan-#{n}" }
    price_cents { 1000 }
    currency { 'EUR' }
    billing_period { 'monthly' }
    posts_limit { 60 }
    disk_space_mb { 100 }
    features { {} }
    active { true }
    position { 0 }

    after(:build) do |price_plan, evaluator|
      generated_name = evaluator.plan_name || "Plan #{price_plan.slug}"
      price_plan.write_attribute(:name, generated_name)
      price_plan.name_i18n = { 'en' => generated_name, 'pl' => "Plan #{generated_name}" }
      price_plan.description_i18n = { 'en' => 'Description', 'pl' => 'Opis' }
    end

    trait :free do
      plan_name { 'Free' }
      slug { 'free' }
      price_cents { 0 }
      posts_limit { 30 }
      disk_space_mb { 40 }
      features do
        {
          'basic_themes' => true,
          'chat_access' => true,
          'forum_read' => true
        }
      end
    end

    trait :basic do
      plan_name { 'Basic' }
      slug { 'basic' }
      price_cents { 1000 }
      posts_limit { 60 }
      disk_space_mb { 100 }
      features do
        {
          'basic_themes' => true,
          'external_video' => true,
          'analytics' => true,
          'chat_access' => true,
          'forum_read' => true,
          'forum_write' => true,
          'live_creator' => true
        }
      end
    end

    trait :professional do
      plan_name { 'Professional' }
      slug { 'professional' }
      price_cents { 5000 }
      posts_limit { 90 }
      disk_space_mb { 1024 }
      features do
        {
          'basic_themes' => true,
          'premium_themes' => true,
          'self_hosted_video' => true,
          'external_video' => true,
          'vanity_domain' => true,
          'advertising' => true,
          'analytics' => true,
          'google_analytics' => true,
          'export_data' => true,
          'chat_access' => true,
          'chat_documents' => true,
          'forum_read' => true,
          'forum_write' => true,
          'forum_private' => true,
          'live_creator' => true
        }
      end
    end

    trait :enterprise do
      plan_name { 'Enterprise' }
      slug { 'enterprise' }
      price_cents { 20_000 }
      posts_limit { nil } # Unlimited
      disk_space_mb { 20_480 }
      features do
        {
          'basic_themes' => true,
          'premium_themes' => true,
          'custom_theme' => true,
          'self_hosted_video' => true,
          'external_video' => true,
          'vanity_domain' => true,
          'advertising' => true,
          'analytics' => true,
          'google_analytics' => true,
          'export_data' => true,
          'remove_branding' => true,
          'priority_support' => true,
          'delegation' => true,
          'ai_assistant' => true,
          'chat_access' => true,
          'chat_documents' => true,
          'chat_video' => true,
          'forum_read' => true,
          'forum_write' => true,
          'forum_private' => true,
          'live_creator' => true,
          'reputation_moderator' => true
        }
      end
    end
  end
end
