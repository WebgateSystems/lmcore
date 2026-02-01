# frozen_string_literal: true

return unless Theme.count.zero?

log('Creating Themes...')

# Default system theme
Theme.create!(
  name: 'Default',
  slug: 'default',
  description: 'Clean and modern default theme with responsive design',
  author: 'LibreMedia Team',
  version: '1.0.0',
  status: 'default',
  is_system: true,
  is_premium: false,
  config: {
    'layout' => 'standard',
    'sidebar' => true,
    'sidebar_position' => 'right',
    'footer' => true,
    'header_sticky' => true,
    'max_width' => '1200px'
  },
  color_scheme: {
    'primary' => '#2563eb',
    'secondary' => '#64748b',
    'accent' => '#f59e0b',
    'background' => '#ffffff',
    'surface' => '#f8fafc',
    'text' => '#1e293b',
    'text_muted' => '#64748b',
    'border' => '#e2e8f0',
    'success' => '#22c55e',
    'warning' => '#f59e0b',
    'error' => '#ef4444'
  }
)

# Dark mode variant
Theme.create!(
  name: 'Dark Mode',
  slug: 'dark',
  description: 'Dark theme for comfortable reading at night',
  author: 'LibreMedia Team',
  version: '1.0.0',
  status: 'active',
  is_system: true,
  is_premium: false,
  config: {
    'layout' => 'standard',
    'sidebar' => true,
    'sidebar_position' => 'right',
    'footer' => true,
    'header_sticky' => true,
    'max_width' => '1200px'
  },
  color_scheme: {
    'primary' => '#3b82f6',
    'secondary' => '#94a3b8',
    'accent' => '#fbbf24',
    'background' => '#0f172a',
    'surface' => '#1e293b',
    'text' => '#f1f5f9',
    'text_muted' => '#94a3b8',
    'border' => '#334155',
    'success' => '#22c55e',
    'warning' => '#f59e0b',
    'error' => '#ef4444'
  }
)

# Minimal theme
Theme.create!(
  name: 'Minimal',
  slug: 'minimal',
  description: 'Minimalist theme focusing on content',
  author: 'LibreMedia Team',
  version: '1.0.0',
  status: 'active',
  is_system: true,
  is_premium: false,
  config: {
    'layout' => 'minimal',
    'sidebar' => false,
    'footer' => true,
    'header_sticky' => false,
    'max_width' => '800px'
  },
  color_scheme: {
    'primary' => '#18181b',
    'secondary' => '#71717a',
    'accent' => '#18181b',
    'background' => '#ffffff',
    'surface' => '#fafafa',
    'text' => '#18181b',
    'text_muted' => '#71717a',
    'border' => '#e4e4e7',
    'success' => '#22c55e',
    'warning' => '#f59e0b',
    'error' => '#ef4444'
  }
)

# Magazine theme (premium)
Theme.create!(
  name: 'Magazine',
  slug: 'magazine',
  description: 'Professional magazine-style layout for news and media',
  author: 'LibreMedia Team',
  version: '1.0.0',
  status: 'active',
  is_system: true,
  is_premium: true,
  config: {
    'layout' => 'magazine',
    'sidebar' => true,
    'sidebar_position' => 'left',
    'footer' => true,
    'header_sticky' => true,
    'max_width' => '1400px',
    'featured_posts' => true,
    'categories_menu' => true
  },
  color_scheme: {
    'primary' => '#dc2626',
    'secondary' => '#737373',
    'accent' => '#dc2626',
    'background' => '#ffffff',
    'surface' => '#f5f5f5',
    'text' => '#171717',
    'text_muted' => '#737373',
    'border' => '#e5e5e5',
    'success' => '#22c55e',
    'warning' => '#f59e0b',
    'error' => '#ef4444'
  }
)

# Blog theme (premium)
Theme.create!(
  name: 'Personal Blog',
  slug: 'personal-blog',
  description: 'Warm and personal theme for individual bloggers',
  author: 'LibreMedia Team',
  version: '1.0.0',
  status: 'active',
  is_system: true,
  is_premium: true,
  config: {
    'layout' => 'blog',
    'sidebar' => true,
    'sidebar_position' => 'right',
    'footer' => true,
    'header_sticky' => false,
    'max_width' => '1000px',
    'author_bio' => true,
    'reading_time' => true
  },
  color_scheme: {
    'primary' => '#7c3aed',
    'secondary' => '#a78bfa',
    'accent' => '#f472b6',
    'background' => '#faf5ff',
    'surface' => '#ffffff',
    'text' => '#1e1b4b',
    'text_muted' => '#6b7280',
    'border' => '#e9d5ff',
    'success' => '#22c55e',
    'warning' => '#f59e0b',
    'error' => '#ef4444'
  }
)

log("Created #{Theme.count} themes")
