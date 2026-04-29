# frozen_string_literal: true

class SplitAmThemeFromDefault < ActiveRecord::Migration[8.1]
  def up
    default_theme = Theme.find_or_initialize_by(slug: "default")
    default_theme.assign_attributes(
      name: "Default",
      description: "Clean editorial blog theme with sidebar, language switcher, and light/dark modes",
      author: "LibreMedia Team",
      version: default_theme.version.presence || "1.0.0",
      path: "default",
      status: "default",
      is_system: true,
      is_premium: false,
      price_cents: 0
    )
    default_theme.save!

    Theme.where(status: "default").where.not(id: default_theme.id).update_all(status: "active")

    am_theme = Theme.find_or_initialize_by(slug: "am")
    am_theme.assign_attributes(
      name: "AM",
      description: "Dedicated custom theme for Ayder Muzhdabaev's blog - editorial style with multilingual support",
      author: am_theme.author.presence || "LibreMedia Team",
      version: am_theme.version.presence || "1.0.0",
      path: "am",
      status: "active",
      is_system: false,
      is_premium: false,
      price_cents: 0
    )
    am_theme.save!

    ayder = User.find_by(username: "am")
    return unless ayder

    user_theme = UserTheme.find_or_initialize_by(user: ayder, theme: am_theme)
    user_theme.active = true
    user_theme.save!

    ThemeAccess.find_or_create_by!(theme: am_theme, user: ayder)
  end

  def down
    am_theme = Theme.find_by(slug: "am")
    return unless am_theme

    Theme.where(status: "default").where.not(id: am_theme.id).update_all(status: "active")
    am_theme.update!(status: "default")
  end
end
