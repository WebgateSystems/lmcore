# frozen_string_literal: true

module Dashboard
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_dashboard_access!
    skip_after_action :verify_authorized, only: :switch_locale
    skip_after_action :verify_policy_scoped, only: :switch_locale

    layout "dashboard"
    helper_method :dashboard_available_locales, :dashboard_locale_name,
                  :dashboard_blog_user, :dashboard_workspace_options,
                  :dashboard_workspace_role_names, :own_dashboard_workspace?,
                  :dashboard_can_author?, :dashboard_can_edit?,
                  :dashboard_can_moderate?

    DashboardPunditContext = Struct.new(:user, :dashboard_blog_user, keyword_init: true)

    def switch_locale
      locale = LocaleTags.canonical_locale_code(params[:interface_locale])

      if locale.present? && dashboard_available_locales.include?(locale)
        session[:locale] = locale
        cookies[:locale] = { value: locale, expires: 1.year.from_now }
      end

      redirect_to dashboard_return_path_without_locale
    end

    private

    def pundit_user
      DashboardPunditContext.new(user: current_user, dashboard_blog_user: dashboard_blog_user)
    end

    def default_url_options
      super.except(:locale)
    end

    def dashboard_available_locales
      @dashboard_available_locales ||= SiteSetting.blog_available_locale_codes_for(dashboard_blog_user)
    end

    def dashboard_locale_name(locale_code)
      LocaleTags.native_name(locale_code)
    end

    def dashboard_blog_user
      @dashboard_blog_user ||= begin
        selected = dashboard_workspace_options.find { |user| user.id == session[:dashboard_blog_user_id] }
        selected || current_user
      end
    end

    def dashboard_workspace_options
      @dashboard_workspace_options ||= begin
        blog_user_ids = RoleAssignment
                        .active
                        .where(user: current_user, scope_type: "User")
                        .where.not(scope_id: nil)
                        .distinct
                        .pluck(:scope_id)

        others = User.active.where(id: blog_user_ids).order(:username, :email).to_a
        ([ current_user ] + others).uniq(&:id)
      end
    end

    def dashboard_workspace_role_names
      return [ I18n.t("dashboard.workspace.owner", default: "Owner") ] if own_dashboard_workspace?

      dashboard_role_assignments.includes(:role).map { |assignment| assignment.role.name }.compact
    end

    def own_dashboard_workspace?
      current_user == dashboard_blog_user
    end

    def dashboard_can_author?
      own_dashboard_workspace? || current_user.can_author?(dashboard_blog_user)
    end

    def dashboard_can_edit?
      own_dashboard_workspace? || current_user.can_edit?(dashboard_blog_user)
    end

    def dashboard_can_moderate?
      own_dashboard_workspace? || current_user.can_moderate?(dashboard_blog_user)
    end

    def dashboard_role_assignments
      @dashboard_role_assignments ||= RoleAssignment
                                      .active
                                      .for_blog(dashboard_blog_user)
                                      .where(user: current_user)
    end

    def can_access_dashboard_workspace?
      own_dashboard_workspace? || dashboard_role_assignments.exists?
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
      unless current_user.dashboard_user? && can_access_dashboard_workspace?
        session.delete(:dashboard_blog_user_id)
        redirect_to root_path, alert: I18n.t("dashboard.access_denied", default: "You don't have permission to access the dashboard.")
      end
    end

    def require_moderator!
      unless own_dashboard_workspace? || current_user.can_moderate?(dashboard_blog_user)
        redirect_to dashboard_root_path, alert: I18n.t("dashboard.moderator_required", default: "This section requires moderator privileges.")
      end
    end

    # The /dashboard area is a per-blog workspace. `current_user` is always the
    # actor; `dashboard_blog_user` is the blog currently being managed.
    def scoped_posts
      Post.where(author: dashboard_blog_user)
    end

    def scoped_videos
      Video.where(author: dashboard_blog_user)
    end

    def scoped_photos
      Photo.where(author: dashboard_blog_user)
    end

    def scoped_albums
      Album.where(author: dashboard_blog_user)
    end

    def scoped_pages
      Page.where(author: dashboard_blog_user)
    end

    def scoped_categories
      Category.where(user: dashboard_blog_user)
    end

    # "My comments" on the dashboard means comments left under MY content
    # (so I can moderate them), not comments I have written elsewhere.
    def scoped_comments
      Comment.where(commentable_type: "Post", commentable_id: scoped_posts.select(:id))
             .or(Comment.where(commentable_type: "Video", commentable_id: scoped_videos.select(:id)))
             .or(Comment.where(commentable_type: "Album", commentable_id: scoped_albums.select(:id)))
    end
  end
end
