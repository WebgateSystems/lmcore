# frozen_string_literal: true

return unless PricePlan.count.zero?

log('Creating Price Plans...')

[
  {
    name: 'Free',
    slug: 'free',
    name_i18n: { 'en' => 'Free', 'pl' => 'Darmowy', 'uk' => 'Безкоштовний', 'lt' => 'Nemokamas' },
    description_i18n: {
      'en' => 'Get started for free with basic features',
      'pl' => 'Zacznij za darmo z podstawowymi funkcjami',
      'uk' => 'Почніть безкоштовно з базовими функціями',
      'lt' => 'Pradėkite nemokamai su pagrindinėmis funkcijomis'
    },
    price_cents: 0,
    currency: 'EUR',
    billing_period: 'monthly',
    posts_limit: 30,
    disk_space_mb: 40,
    features: {
      'basic_themes' => true,
      'chat_access' => true,
      'chat_documents' => false,
      'chat_video' => false,
      'forum_read' => true,
      'forum_write' => false,
      'forum_private' => false,
      'live_viewer' => true,
      'live_creator' => false,
      'reputation_viewer' => true,
      'reputation_moderator' => false,
      'external_video' => false,
      'self_hosted_video' => false,
      'analytics' => false,
      'google_analytics' => false,
      'vanity_domain' => false,
      'advertising' => false,
      'export_data' => false,
      'remove_branding' => false,
      'priority_support' => false,
      'delegation' => false,
      'ai_assistant' => false
    },
    position: 0
  },
  {
    name: 'Basic',
    slug: 'basic',
    name_i18n: { 'en' => 'Basic', 'pl' => 'Podstawowy', 'uk' => 'Базовий', 'lt' => 'Bazinis' },
    description_i18n: {
      'en' => 'Perfect for individual bloggers and content creators',
      'pl' => 'Idealny dla indywidualnych blogerów i twórców treści',
      'uk' => 'Ідеально для індивідуальних блогерів та творців контенту',
      'lt' => 'Puikiai tinka individualiems tinklaraštininkams ir turinio kūrėjams'
    },
    price_cents: 1000,
    currency: 'EUR',
    billing_period: 'monthly',
    posts_limit: 60,
    disk_space_mb: 100,
    features: {
      'basic_themes' => true,
      'chat_access' => true,
      'chat_documents' => false,
      'chat_video' => false,
      'forum_read' => true,
      'forum_write' => true,
      'forum_private' => false,
      'live_viewer' => true,
      'live_creator' => true,
      'live_high_fee' => true,
      'reputation_viewer' => true,
      'reputation_moderator' => false,
      'external_video' => true,
      'self_hosted_video' => false,
      'analytics' => true,
      'google_analytics' => false,
      'vanity_domain' => false,
      'advertising' => false,
      'export_data' => false,
      'remove_branding' => false,
      'priority_support' => false,
      'delegation' => false,
      'ai_assistant' => false
    },
    position: 1
  },
  {
    name: 'Professional',
    slug: 'professional',
    name_i18n: { 'en' => 'Professional', 'pl' => 'Profesjonalny', 'uk' => 'Професійний', 'lt' => 'Profesionalus' },
    description_i18n: {
      'en' => 'For serious content creators and small media outlets',
      'pl' => 'Dla poważnych twórców treści i małych mediów',
      'uk' => 'Для серйозних творців контенту та невеликих ЗМІ',
      'lt' => 'Rimtiems turinio kūrėjams ir mažoms žiniasklaidos priemonėms'
    },
    price_cents: 5000,
    currency: 'EUR',
    billing_period: 'monthly',
    posts_limit: 90,
    disk_space_mb: 1024,
    features: {
      'basic_themes' => true,
      'premium_themes' => true,
      'chat_access' => true,
      'chat_documents' => true,
      'chat_video' => false,
      'forum_read' => true,
      'forum_write' => true,
      'forum_private' => true,
      'live_viewer' => true,
      'live_creator' => true,
      'live_medium_fee' => true,
      'reputation_viewer' => true,
      'reputation_moderator' => false,
      'external_video' => true,
      'self_hosted_video' => true,
      'analytics' => true,
      'google_analytics' => true,
      'vanity_domain' => true,
      'advertising' => true,
      'export_data' => true,
      'remove_branding' => false,
      'priority_support' => true,
      'support_3_days' => true,
      'delegation' => false,
      'ai_assistant' => false
    },
    position: 2
  },
  {
    name: 'Enterprise',
    slug: 'enterprise',
    name_i18n: { 'en' => 'Enterprise', 'pl' => 'Enterprise', 'uk' => 'Enterprise', 'lt' => 'Enterprise' },
    description_i18n: {
      'en' => 'Full functionality for media companies and public opinion leaders',
      'pl' => 'Pełna funkcjonalność dla firm medialnych i liderów opinii publicznej',
      'uk' => 'Повна функціональність для медіакомпаній та лідерів громадської думки',
      'lt' => 'Pilnas funkcionalumas žiniasklaidos įmonėms ir visuomenės nuomonės lyderiams'
    },
    price_cents: 20_000,
    currency: 'EUR',
    billing_period: 'monthly',
    posts_limit: nil, # Unlimited
    disk_space_mb: 20_480,
    features: {
      'basic_themes' => true,
      'premium_themes' => true,
      'custom_theme' => true,
      'chat_access' => true,
      'chat_documents' => true,
      'chat_video' => true,
      'forum_read' => true,
      'forum_write' => true,
      'forum_private' => true,
      'live_viewer' => true,
      'live_creator' => true,
      'live_low_fee' => true,
      'reputation_viewer' => true,
      'reputation_moderator' => true,
      'external_video' => true,
      'self_hosted_video' => true,
      'analytics' => true,
      'google_analytics' => true,
      'vanity_domain' => true,
      'advertising' => true,
      'export_data' => true,
      'remove_branding' => true,
      'priority_support' => true,
      'support_1_day' => true,
      'delegation' => true,
      'ai_assistant' => true,
      'feature_requests' => true,
      'dedicated_design' => true
    },
    position: 3
  }
].each do |data|
  plan = PricePlan.new(data.except(:name, :name_i18n, :description_i18n))
  plan.write_attribute(:name, data[:name])
  plan.name_i18n = data[:name_i18n]
  plan.description_i18n = data[:description_i18n]
  plan.save!
end

log("Created #{PricePlan.count} price plans")
