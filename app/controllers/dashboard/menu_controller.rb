# frozen_string_literal: true

module Dashboard
  class MenuController < BaseController
    def show
      authorize :menu, policy_class: Dashboard::MenuPolicy
      @menu_items = editor_menu_items
    end

    def update
      authorize :menu, policy_class: Dashboard::MenuPolicy

      payload = menu_params
      BlogNavigationMenu.new(user: current_user).save!(
        order_ids: payload[:order],
        visibility_by_id: payload[:visibility] || {}
      )

      redirect_to dashboard_menu_path, notice: t("dashboard.menu.flash.saved", default: "Menu saved.")
    rescue ArgumentError => e
      redirect_to dashboard_menu_path, alert: e.message
    rescue ActiveRecord::RecordInvalid => e
      redirect_to dashboard_menu_path, alert: t("dashboard.menu.flash.failed", default: "Failed to save menu: %{error}", error: e.message)
    end

    private

    def menu_params
      params.require(:menu).permit(order: [], visibility: {})
    end

    def editor_menu_items
      BlogNavigationMenu.new(user: current_user).items.map do |item|
        {
          id: item[:id],
          kind: item[:kind],
          visible: item[:visible],
          title: menu_item_title(item),
          path: menu_item_path(item),
          page: item[:page]
        }
      end
    end

    def menu_item_title(item)
      return t("dashboard.menu.items.#{item[:id]}", default: item[:id].humanize) if item[:kind] == "static"

      page = item[:page]
      return item[:slug].to_s.humanize unless page

      localized_page_value(page.display_menu_title)
    end

    def menu_item_path(item)
      return "/" if item[:id] == "home"

      if item[:kind] == "static"
        case item[:id]
        when "about" then "/pages/about"
        when "videos" then "/videos"
        when "posts" then "/posts"
        when "gallery" then "/gallery"
        else "/"
        end
      else
        "/pages/#{item[:slug]}"
      end
    end

    def localized_page_value(value)
      return value.to_s unless value.is_a?(Hash)

      locale = I18n.locale.to_s
      value[locale].presence ||
        value[I18n.default_locale.to_s].presence ||
        value.values.find(&:present?).to_s
    end
  end
end
