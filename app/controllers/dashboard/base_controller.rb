# frozen_string_literal: true

module Dashboard
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_dashboard_access!
    skip_after_action :verify_authorized, only: :switch_locale
    skip_after_action :verify_policy_scoped, only: :switch_locale

    layout "dashboard"
    helper_method :dashboard_available_locales, :dashboard_locale_name

    def switch_locale
      locale = LocaleTags.canonical_locale_code(params[:interface_locale])

      if locale.present? && dashboard_available_locales.include?(locale)
        session[:locale] = locale
        cookies[:locale] = { value: locale, expires: 1.year.from_now }
      end

      redirect_to dashboard_return_path_without_locale
    end

    private

    def default_url_options
      super.except(:locale)
    end

    def dashboard_available_locales
      @dashboard_available_locales ||= SiteSetting.blog_available_locale_codes_for(current_user)
    end

    def dashboard_locale_name(locale_code)
      LocaleTags.native_name(locale_code)
    end

    def dashboard_return_path_without_locale
      fallback = dashboard_root_path(locale: nil)
      referer = request.referer.to_s
      return fallback if referer.blank?

      uri = URI.parse(referer)
      return fallback unless uri.path.start_with?("/dashboard")

      query = Rack::Utils.parse_nested_query(uri.query).except("locale", "interface_locale")
      clean_query = query.present? ? "?#{query.to_query}" : ""
      clean_fragment = uri.fragment.present? ? "##{uri.fragment}" : ""
      "#{uri.path}#{clean_query}#{clean_fragment}"
    rescue URI::InvalidURIError
      fallback
    end

    def require_dashboard_access!
      unless current_user.author? || current_user.moderator? || current_user.admin?
        redirect_to root_path, alert: I18n.t("dashboard.access_denied", default: "You don't have permission to access the dashboard.")
      end
    end

    def require_moderator!
      unless current_user.moderator? || current_user.admin?
        redirect_to dashboard_root_path, alert: I18n.t("dashboard.moderator_required", default: "This section requires moderator privileges.")
      end
    end

    # The /dashboard area is the per-blog workspace. Even moderators and
    # admins only see their OWN content here -- cross-blog moderation lives
    # under /admin. Do NOT add a role-based bypass to these scopes.
    def scoped_posts
      Post.where(author: current_user)
    end

    def scoped_videos
      Video.where(author: current_user)
    end

    def scoped_photos
      Photo.where(author: current_user)
    end

    def scoped_pages
      Page.where(author: current_user)
    end

    def scoped_categories
      Category.where(user: current_user)
    end

    # "My comments" on the dashboard means comments left under MY content
    # (so I can moderate them), not comments I have written elsewhere.
    def scoped_comments
      Comment.where(commentable_type: "Post", commentable_id: scoped_posts.select(:id))
             .or(Comment.where(commentable_type: "Video", commentable_id: scoped_videos.select(:id)))
             .or(Comment.where(commentable_type: "Photo", commentable_id: scoped_photos.select(:id)))
    end
  end
end
