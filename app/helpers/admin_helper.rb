# frozen_string_literal: true

module AdminHelper
  def user_status_badge_class(user)
    case user.status
    when "active"
      "md-bg-green-500"
    when "pending"
      "md-bg-amber-500"
    when "suspended"
      "md-bg-red-500"
    when "deleted"
      "md-bg-grey-500"
    else
      "md-bg-blue-grey-500"
    end
  end

  def user_role_badge_class(user)
    # Use highest role from role_assignments (multi-role system)
    highest_role = user.highest_role
    role_slug = highest_role&.slug

    case role_slug
    when "super-admin"
      "md-bg-purple-500"
    when "admin"
      "md-bg-blue-500"
    when "moderator"
      "md-bg-cyan-500"
    when "editor"
      "md-bg-indigo-500"
    when "author"
      "md-bg-teal-500"
    when "user"
      "md-bg-green-500"
    else
      "md-bg-blue-grey-500"
    end
  end

  def role_badge_class(role)
    case role&.slug
    when "super-admin"
      "md-bg-purple-500"
    when "admin"
      "md-bg-blue-500"
    when "moderator"
      "md-bg-cyan-500"
    when "editor"
      "md-bg-indigo-500"
    when "author"
      "md-bg-teal-500"
    when "user"
      "md-bg-green-500"
    else
      "md-bg-blue-grey-500"
    end
  end

  def activity_badge_class(action)
    case action.to_s.downcase
    when /create/, /add/, /new/
      "md-bg-green-500"
    when /update/, /edit/, /change/
      "md-bg-blue-500"
    when /delete/, /destroy/, /remove/
      "md-bg-red-500"
    when /suspend/, /ban/, /block/
      "md-bg-orange-500"
    when /activate/, /approve/, /publish/
      "md-bg-green-500"
    when /login/, /sign_in/
      "md-bg-blue-500"
    when /logout/, /sign_out/
      "md-bg-grey-500"
    else
      "md-bg-blue-grey-500"
    end
  end

  def activity_icon_class(action)
    case action.to_s.downcase
    when /create/, /add/, /new/
      "mdi-plus-circle md-color-green-600"
    when /update/, /edit/, /change/
      "mdi-pencil md-color-blue-600"
    when /delete/, /destroy/, /remove/
      "mdi-delete md-color-red-600"
    when /suspend/, /ban/, /block/
      "mdi-account-cancel md-color-orange-600"
    when /activate/, /approve/
      "mdi-check-circle md-color-green-600"
    when /login/, /sign_in/
      "mdi-login md-color-blue-600"
    when /logout/, /sign_out/
      "mdi-logout md-color-grey-600"
    when /publish/
      "mdi-publish md-color-green-600"
    when /unpublish/, /draft/
      "mdi-eye-off md-color-amber-600"
    else
      "mdi-information md-color-blue-grey-600"
    end
  end

  def format_bytes(bytes)
    return "0 B" if bytes.nil? || bytes.zero?

    units = %w[B KB MB GB TB]
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = units.length - 1 if exp > units.length - 1
    "%.1f %s" % [ bytes.to_f / (1024**exp), units[exp] ]
  end

  def admin_page_title(title)
    content_for(:title, "#{title} - Admin Panel - LibreMedia")
    content_tag(:h2, title, class: "uk-heading-small uk-margin-remove-top")
  end

  def admin_breadcrumb(*items)
    content_tag(:ul, class: "uk-breadcrumb uk-margin-remove-bottom") do
      items.map.with_index do |item, index|
        if index == items.length - 1
          content_tag(:li) { content_tag(:span, item[:title]) }
        else
          content_tag(:li) { link_to(item[:title], item[:path]) }
        end
      end.join.html_safe
    end
  end

  def sortable_column(column, title, current_sort, current_direction)
    direction = (current_sort == column.to_s && current_direction == "asc") ? "desc" : "asc"
    icon = if current_sort == column.to_s
             current_direction == "asc" ? "mdi-arrow-up" : "mdi-arrow-down"
    else
             "mdi-arrow-up-down"
    end

    link_to(url_for(sort: column, direction: direction), class: "uk-flex uk-flex-middle") do
      content_tag(:span, title) +
        content_tag(:i, "", class: "mdi #{icon} uk-margin-small-left")
    end
  end
end
