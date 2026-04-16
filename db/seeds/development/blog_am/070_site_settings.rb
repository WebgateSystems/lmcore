# frozen_string_literal: true

ayder = User.find_by!(email: 'ayder@gmail.com')
return if SiteSetting.for_user(ayder).exists?

log('  [Blog AM] Creating site settings...')

settings = [
  { key: 'site_name', value: { 'en' => 'Ayder Muzhdabaiev', 'uk' => 'Айдер Муждабаєв', 'ru' => 'Айдер Муждабаев', 'pl' => 'Ajder Mużdabajew' }, category: 'general', value_type: 'json' },
  { key: 'site_tagline', value: { 'en' => 'Journalist', 'uk' => 'Журналіст', 'ru' => 'Журналист', 'pl' => 'Dziennikarz' }, category: 'general', value_type: 'json' },
  { key: 'default_locale', value: 'uk', category: 'general', value_type: 'string' },
  { key: 'available_locales', value: %w[en uk ru pl], category: 'general', value_type: 'json' },
  { key: 'posts_per_page', value: 10, category: 'general', value_type: 'integer' },
  { key: 'comments_enabled', value: true, category: 'general', value_type: 'boolean' },
  { key: 'comments_moderation', value: true, category: 'general', value_type: 'boolean' },
  { key: 'site_description', value: { 'en' => 'Personal blog of Ayder Muzhdabaiev', 'uk' => 'Особистий блог Айдера Муждабаєва', 'ru' => 'Личный блог Айдера Муждабаева', 'pl' => 'Osobisty blog Ajdera Muzhdabajewa' }, category: 'seo', value_type: 'json' },
  { key: 'analytics_id', value: '', category: 'seo', value_type: 'string' },
  { key: 'facebook_url', value: 'https://www.facebook.com/aider.muzhdabaiev', category: 'social', value_type: 'string' },
  { key: 'youtube_url', value: 'https://www.youtube.com/@AyderMuzhdabaev', category: 'social', value_type: 'string' },
  { key: 'instagram_url', value: 'https://www.instagram.com/aydermuzhdabaev/', category: 'social', value_type: 'string' },
  { key: 'threads_url', value: 'https://www.threads.com/@aydermuzhdabaev', category: 'social', value_type: 'string' },
  { key: 'bluesky_url', value: 'https://bsky.app/profile/ayder.bsky.social', category: 'social', value_type: 'string' },
  { key: 'active_theme', value: 'am', category: 'appearance', value_type: 'string' }
]

settings.each do |s|
  SiteSetting.create!(
    key: s[:key],
    value: { 'data' => s[:value] },
    category: s[:category],
    value_type: s[:value_type],
    user: ayder
  )
end

log("  [Blog AM] Created #{SiteSetting.for_user(ayder).count} site settings")
