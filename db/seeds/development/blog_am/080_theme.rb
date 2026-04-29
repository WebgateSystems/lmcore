# frozen_string_literal: true

ayder = User.find_by!(email: 'ayder@gmail.com')

log('  [Blog AM] Setting up theme...')

theme = Theme.find_or_create_by!(slug: 'am') do |t|
  t.name = 'AM'
  t.description = 'Dedicated custom theme for Ayder Muzhdabaev\'s blog — editorial style with multilingual support'
  t.author = 'LibreMedia Team'
  t.version = '1.0.0'
  t.path = 'am'
  t.status = 'active'
  t.is_system = false
  t.is_premium = false
  t.config = {
    'layout' => 'editorial',
    'sidebar' => false,
    'footer' => true,
    'header_sticky' => true,
    'max_width' => '1400px',
    'featured_posts' => true,
    'categories_menu' => true,
    'dark_header' => true,
    'language_switcher' => true
  }
  t.color_scheme = {
    'primary' => '#e41e13',
    'secondary' => '#333333',
    'accent' => '#e41e13',
    'background' => '#ffffff',
    'surface' => '#f5f5f5',
    'text' => '#1a1a1a',
    'text_muted' => '#666666',
    'border' => '#e0e0e0',
    'header_bg' => '#1a1a1a',
    'header_text' => '#ffffff'
  }
end
theme.update!(
  name: 'AM',
  description: 'Dedicated custom theme for Ayder Muzhdabaev\'s blog — editorial style with multilingual support',
  path: 'am',
  status: 'active',
  is_system: false,
  is_premium: false
)

user_theme = UserTheme.find_or_create_by!(user: ayder, theme: theme)
user_theme.update!(active: true)

log("  [Blog AM] Theme '#{theme.name}' assigned to #{ayder.email}")
