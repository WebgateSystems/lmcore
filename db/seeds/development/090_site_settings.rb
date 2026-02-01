# frozen_string_literal: true

return unless SiteSetting.count.zero?

log('Creating Site Settings...')

# Helper to create site setting with proper value format
def create_setting(key:, value:, category: 'general', value_type: nil)
  inferred_type = case value
  when TrueClass, FalseClass then 'boolean'
  when Integer then 'integer'
  when Hash, Array then 'json'
  else 'string'
  end

  SiteSetting.create!(
    key: key,
    value: { 'data' => value },
    category: category,
    value_type: value_type || inferred_type
  )
end

# General settings
create_setting(key: 'site_name', value: 'LibreMedia', category: 'general')
create_setting(key: 'site_tagline', value: 'Free Speech, Free Media', category: 'general')
create_setting(key: 'site_description', value: 'Independent multimedia publishing platform for free speech', category: 'general')
create_setting(key: 'default_locale', value: 'en', category: 'general')
create_setting(key: 'supported_locales', value: %w[en pl uk lt], category: 'general')
create_setting(key: 'timezone', value: 'Europe/Warsaw', category: 'general')

# Content settings
create_setting(key: 'posts_per_page', value: 20, category: 'content')
create_setting(key: 'enable_comments', value: true, category: 'content')
create_setting(key: 'moderate_comments', value: true, category: 'content')
create_setting(key: 'enable_reactions', value: true, category: 'content')
create_setting(key: 'max_upload_size_mb', value: 50, category: 'content')
create_setting(key: 'allowed_file_types', value: %w[jpg jpeg png gif webp mp4 webm pdf], category: 'content')

# Registration settings
create_setting(key: 'allow_registration', value: true, category: 'registration')
create_setting(key: 'require_email_confirmation', value: true, category: 'registration')
create_setting(key: 'default_role', value: 'user', category: 'registration')
create_setting(key: 'default_plan', value: 'free', category: 'registration')

# Security settings
create_setting(key: 'rate_limit_requests', value: 100, category: 'security')
create_setting(key: 'rate_limit_period', value: 60, category: 'security')
create_setting(key: 'block_suspicious_ips', value: true, category: 'security')
create_setting(key: 'enable_2fa', value: true, category: 'security')
create_setting(key: 'session_timeout_minutes', value: 1440, category: 'security')

# Email settings
create_setting(key: 'email_from', value: 'noreply@libremedia.org', category: 'email')
create_setting(key: 'email_reply_to', value: 'support@libremedia.org', category: 'email')

# Social settings
create_setting(key: 'twitter_handle', value: '@libremedia', category: 'social')
create_setting(key: 'telegram_channel', value: 'libremedia', category: 'social')

# Feature flags
create_setting(key: 'feature_chat_enabled', value: true, category: 'features')
create_setting(key: 'feature_forum_enabled', value: true, category: 'features')
create_setting(key: 'feature_live_enabled', value: true, category: 'features')
create_setting(key: 'feature_reputation_enabled', value: true, category: 'features')
create_setting(key: 'feature_donations_enabled', value: true, category: 'features')

# Monetization settings
create_setting(key: 'platform_fee_percentage', value: 5, category: 'monetization')
create_setting(key: 'min_donation_amount', value: 100, category: 'monetization') # in cents
create_setting(key: 'supported_currencies', value: %w[EUR USD PLN UAH], category: 'monetization')

log("Created #{SiteSetting.count} site settings")
