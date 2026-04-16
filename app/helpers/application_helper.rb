module ApplicationHelper
  include Pagy::Frontend

  def locale_ui_tag(locale = I18n.locale)
    LocaleTags.ui_tag(locale)
  end

  def locale_native_name(locale = I18n.locale)
    LocaleTags.native_name(locale)
  end

  def locale_menu_label(locale = I18n.locale)
    LocaleTags.menu_label(locale)
  end

  # Value for `locale:` in routes and switch_locale_path (e.g. :uk → "ua")
  def locale_path_segment(locale = I18n.locale)
    c = LocaleTags.canonical_locale_code(locale) || I18n.default_locale.to_s
    LocaleTags.path_segment_for_canonical(c)
  end

  # Locales listed in the public home nav language dropdown (subset of platform locales).
  def home_locale_switcher_locales
    LocaleTags.home_language_switcher_locales
  end

  # Pairs for user.locale <select>: values are blog-configured locales (SiteSetting), not full platform list.
  def locale_select_options_for_user(user = nil)
    user ||= current_user
    return I18n.available_locales.map { |l| [ LocaleTags.menu_label(l), l.to_s ] } unless user

    SiteSetting.blog_available_locale_codes_for(user).map { |c| [ LocaleTags.menu_label(c), c ] }
  end
end
