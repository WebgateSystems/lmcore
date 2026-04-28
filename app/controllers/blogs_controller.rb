# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :set_blog_owner
  before_action :set_theme_renderer
  before_action :set_locale_from_blog

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # Any `find_by!` / `find` miss inside a blog action (post, video, photo,
  # page, category, tag — and also `set_blog_owner` for an unknown blog
  # username) is funnelled here. We render a themed 404 page when the active
  # theme provides one, and fall back to the static `public/404.html` if the
  # blog owner / renderer could not be resolved.
  rescue_from ActiveRecord::RecordNotFound, with: :render_blog_not_found

  def show
    # Each column on the homepage (post / video / photo) gets a "top" pick
    # (author-pinned via Publishable#toggle_pinned!, nil when nothing is
    # pinned) and a "latest" pick (the most recent item).
    #
    # We try to avoid duplicating Top in Latest -- but only when there's
    # something else to show. If the author has exactly one photo and it
    # happens to be pinned as Top, the second-row Latest still shows that
    # same photo instead of an empty state, which is what users expect
    # ("the most recent photo IS this one, even if it's also pinned").
    #
    # The smaller `recent_*` strips below are intentionally stricter --
    # they exclude Top with no fallback, because a strip of "more posts"
    # genuinely shouldn't repeat the headline tile.
    top_post  = pick_top(blog_posts)
    top_video = pick_top(blog_videos)
    top_photo = pick_top(blog_albums)

    latest_post  = pick_latest(blog_posts,  top_post)
    latest_video = pick_latest(blog_videos, top_video)
    latest_photo = pick_latest(blog_albums, top_photo)

    recent_posts  = exclude_record(blog_posts,  top_post).limit(6)
    recent_videos = exclude_record(blog_videos, top_video).limit(4)
    recent_photos = exclude_record(blog_albums, top_photo).limit(6)

    render_theme("index",
      top_post: serialize_post(top_post),
      top_video: serialize_video(top_video),
      top_photo: serialize_album(top_photo),
      latest_post: serialize_post(latest_post),
      latest_video: serialize_video(latest_video),
      latest_photo: serialize_album(latest_photo),
      # Backwards-compat alias for themes still referencing `featured_post`.
      featured_post: serialize_post(top_post),
      posts: recent_posts.map { |p| serialize_post(p) },
      videos: recent_videos.map { |v| serialize_video(v) },
      photos: recent_photos.map { |p| serialize_album(p) },
      categories: serialize_categories,
      tags: popular_tags)
  end

  def post
    post = blog_posts.find_by!(slug: params[:slug])
    post.increment_views!

    related = post.related_posts(limit: 4).map { |p| serialize_post(p) }
    comments = post.comments.approved.root_comments.includes(:replies, :user).oldest

    render_theme("post",
      post: serialize_post(post, full: true),
      comments: comments.map { |c| serialize_comment(c) },
      related_posts: related,
      categories: serialize_categories)
  end

  def posts
    query = params[:q].to_s.strip
    selected_years = Array(params[:year]).reject(&:blank?)
    selected_tags = Array(params[:tag]).reject(&:blank?)
    page = (params[:page] || 1).to_i
    per_page = blog_setting("posts_per_page", 10)
    filtered_posts = apply_post_filters(
      blog_posts,
      query: query,
      years: selected_years,
      tags: selected_tags
    )
    all_posts = filtered_posts.offset((page - 1) * per_page).limit(per_page)
    total = filtered_posts.count

    render_theme("posts/index",
      posts: all_posts.map { |p| serialize_post(p) },
      pagination: { current_page: page, per_page: per_page, total: total, total_pages: (total.to_f / per_page).ceil },
      body_class: "articlespage",
      categories: serialize_categories,
      tags: blog_post_tags,
      years: blog_post_years,
      query: query,
      selected_years: selected_years,
      selected_tags: selected_tags,
      filters_query: filters_query_string(query: query, years: selected_years, tags: selected_tags))
  end

  def page
    pg = @blog_owner.pages.published.find_by!(slug: params[:slug])

    render_theme("page",
      page: serialize_page(pg),
      pages_menu: menu_pages)
  end

  def video
    vid = blog_videos.find_by!(slug: params[:slug])
    vid.increment_views!
    comments = vid.comments.approved.root_comments.includes(:replies, :user).oldest

    render_theme("videos/show",
      video: serialize_video(vid, full: true),
      comments: comments.map { |c| serialize_comment(c) },
      categories: serialize_categories)
  end

  def videos
    query = params[:q].to_s.strip
    selected_years = Array(params[:year]).reject(&:blank?)
    selected_tags = Array(params[:tag]).reject(&:blank?)
    page = (params[:page] || 1).to_i
    per_page = 12
    filtered_videos = apply_video_filters(
      blog_videos,
      query: query,
      years: selected_years,
      tags: selected_tags
    )
    all_videos = filtered_videos.offset((page - 1) * per_page).limit(per_page)
    total = filtered_videos.count

    render_theme("videos/index",
      videos: all_videos.map { |v| serialize_video(v) },
      pagination: { current_page: page, per_page: per_page, total: total, total_pages: (total.to_f / per_page).ceil },
      body_class: "videopage",
      categories: serialize_categories,
      years: blog_video_years,
      tags: blog_video_tags,
      query: query,
      selected_years: selected_years,
      selected_tags: selected_tags,
      filters_query: filters_query_string(query: query, years: selected_years, tags: selected_tags))
  end

  def album
    ph = blog_albums.find_by!(slug: params[:slug])
    ph.increment_views!
    comments = ph.comments.approved.root_comments.includes(:replies, :user).oldest

    render_theme("gallery/show",
      album: serialize_album(ph, full: true),
      comments: comments.map { |c| serialize_comment(c) },
      categories: serialize_categories)
  end

  def gallery
    query = params[:q].to_s.strip
    selected_years = Array(params[:year]).reject(&:blank?)
    selected_tags = Array(params[:tag]).reject(&:blank?)
    page = (params[:page] || 1).to_i
    per_page = 12
    filtered_photos = apply_photo_filters(
      blog_albums,
      query: query,
      years: selected_years,
      tags: selected_tags
    )
    all_photos = filtered_photos.offset((page - 1) * per_page).limit(per_page)
    total = filtered_photos.count

    render_theme("gallery/index",
      albums: all_photos.map { |p| serialize_album(p) },
      pagination: { current_page: page, per_page: per_page, total: total, total_pages: (total.to_f / per_page).ceil },
      body_class: "photopage",
      categories: serialize_categories,
      tags: blog_photo_tags,
      years: blog_photo_years,
      query: query,
      selected_years: selected_years,
      selected_tags: selected_tags,
      filters_query: filters_query_string(query: query, years: selected_years, tags: selected_tags))
  end

  def category
    cat = @blog_owner.categories.find_by!(slug: params[:slug])
    cat_posts = blog_posts.where(category: cat).limit(20)

    render_theme("categories/show",
      category: serialize_category(cat),
      posts: cat_posts.map { |p| serialize_post(p) },
      categories: serialize_categories)
  end

  def tag
    t = Tag.find_by!(slug: params[:slug])
    tagged_posts = blog_posts.joins(:tags).where(tags: { id: t.id }).limit(20)

    render_theme("tags/show",
      tag: { "name" => t.name, "slug" => t.slug, "taggings_count" => t.taggings_count },
      posts: tagged_posts.map { |p| serialize_post(p) },
      categories: serialize_categories)
  end

  def search
    query = params[:q].to_s.strip
    results = query.present? ? blog_posts.search_content(query).limit(20) : []

    render_theme("search/index",
      query: query,
      body_class: "searchpage",
      results: results.map { |p| serialize_post(p) },
      categories: serialize_categories)
  end

  def switch_locale
    allowed = blog_available_locales
    locale = LocaleTags.canonical_locale_code(params[:locale])
    locale = nil unless locale.present? && allowed.include?(locale)
    locale ||= blog_locale_fallback(allowed)
    if locale.present? && I18n.available_locales.map(&:to_s).include?(locale)
      session[:locale] = locale
      I18n.locale = locale.to_sym
    end

    if vanity_request?
      redirect_to "/"
    else
      redirect_to blog_path(blog_slug: @blog_owner.username)
    end
  end

  private

  def vanity_request?
    request.env["ORIGINAL_HOST"].present?
  end

  def set_blog_owner
    @blog_owner = User.active.find_by!(username: params[:blog_slug])
    cookies[:blog_uuid] = { value: @blog_owner.id, expires: 1.year.from_now }
  end

  def set_theme_renderer
    user_theme = @blog_owner.user_themes.active.includes(:theme).first
    theme_slug = user_theme&.theme&.path || user_theme&.theme&.slug || "default"
    @renderer = ThemeRenderer.new(theme_slug)
  end

  def set_locale_from_blog
    allowed = blog_available_locales
    default_raw = blog_setting("default_locale", "en")
    default_canon = LocaleTags.canonical_locale_code(default_raw.to_s) || default_raw.to_s
    default_canon = blog_locale_fallback(allowed) unless allowed.include?(default_canon)

    raw = params[:locale] || session[:locale] || default_canon
    locale = LocaleTags.canonical_locale_code(raw.to_s) || raw.to_s
    locale = blog_locale_fallback(allowed) unless allowed.include?(locale)
    I18n.locale = locale.to_sym if I18n.available_locales.map(&:to_s).include?(locale.to_s)
  end

  def render_theme(template, assigns = {})
    html = @renderer.render(template, common_assigns.merge(assigns))
    render html: html.html_safe, layout: false
  end

  # Renders a polite themed 404 page instead of letting an unhandled
  # `ActiveRecord::RecordNotFound` (post unpublished, video deleted, wrong
  # slug, unknown blog…) bubble up as a 500. Status is `:not_found` so
  # crawlers and monitoring agree this URL is gone.
  def render_blog_not_found(_exception = nil)
    response.headers["X-Robots-Tag"] = "noindex"

    if @blog_owner.present? && @renderer.present? && @renderer.template_exists?("404")
      assigns = common_assigns.merge(
        "page_title" => i18n_theme_translation("errors.not_found", default: "Not found"),
        "not_found_message" => not_found_message_for(params[:action])
      )
      html = @renderer.render("404", assigns)
      render html: html.html_safe, layout: false, status: :not_found
    else
      render html: static_404_html.html_safe, layout: false, status: :not_found
    end
  end

  def static_404_html
    @static_404_html ||= begin
      Rails.public_path.join("404.html").read
    rescue StandardError
      "<!doctype html><meta charset=\"utf-8\"><title>404 Not Found</title>" \
        "<h1>404 Not Found</h1>"
    end
  end

  def not_found_message_for(action)
    key = case action.to_s
    when "post"    then "errors.post_not_found"
    when "video"   then "errors.video_not_found"
    when "photo", "album" then "errors.photo_not_found"
    when "page"    then "errors.page_not_found"
    when "category" then "errors.category_not_found"
    when "tag"     then "errors.tag_not_found"
    else "errors.generic_not_found"
    end
    i18n_theme_translation(key, default: nil)
  end

  # Looks up a key under the active theme's translation namespace
  # (e.g. `themes.am.errors.post_not_found`) with a graceful fallback to the
  # raw key under the global namespace and finally to the supplied default.
  def i18n_theme_translation(key, default: nil)
    scope = "themes.#{active_theme_slug}"
    scoped = I18n.t("#{scope}.#{key}", default: nil)
    return scoped if scoped.present?

    I18n.t(key, default: default)
  rescue I18n::MissingTranslationData
    default
  end

  def common_assigns
    current_ban = current_blog_ban
    flash_payload = flash.to_hash
    notice_message = normalized_flash_message(flash_payload["blog_notice"] || flash_payload[:blog_notice])
    alert_message = normalized_flash_message(flash_payload["blog_alert"] || flash_payload[:blog_alert])
    flash.delete(:blog_notice)
    flash.delete(:blog_alert)

    login_path = if vanity_request?
                   sso_login_path(locale: I18n.locale, return_to: vanity_return_to_path)
    else
                   auth_url_with_return_to(new_user_session_path, request.fullpath)
    end
    register_path = if vanity_request?
                      auth_url_with_return_to(new_user_registration_path, vanity_return_to_path)
    else
                      auth_url_with_return_to(new_user_registration_path, request.fullpath)
    end

    {
      "site" => site_settings_hash,
      "blog" => serialize_blog_owner,
      "locale" => I18n.locale.to_s,
      "base_path" => vanity_request? ? "" : "/blogs/#{@blog_owner.username}",
      "canonical_base_path" => "/blogs/#{@blog_owner.username}",
      "vanity_domain" => request.env["ORIGINAL_HOST"].to_s,
      "theme_slug" => active_theme_slug,
      "theme_translation_scope" => "themes.#{active_theme_slug}",
      "current_url" => request.original_url,
      "current_path_with_query" => request.fullpath,
      "pages_menu" => menu_pages,
      "nav_menu_items" => nav_menu_items,
      "partners" => serialize_partners,
      "available_locales" => blog_available_locales,
      "locale_display" => LocaleTags.ui_tag(I18n.locale),
      "blog_locale_switcher_items" => blog_locale_switcher_items,
      "popular_tags" => popular_tags,
      "csrf_token" => form_authenticity_token,
      "current_user" => serialize_current_user,
      "show_dashboard_link" => show_dashboard_link?,
      "current_user_blog_banned" => current_ban.present?,
      "current_user_blog_ban_reason" => current_ban&.reason.to_s,
      "login_url" => (vanity_request? ? sso_login_path(locale: I18n.locale) : new_user_session_path),
      "register_url" => (vanity_request? ? new_user_registration_path(locale: I18n.locale) : new_user_registration_path),
      "login_return_url" => login_path,
      "register_return_url" => register_path,
      "flash_notice" => notice_message,
      "flash_alert" => alert_message
    }
  end

  def auth_url_with_return_to(base_path, return_to = nil)
    return_to_value = return_to.to_s
    return base_path if return_to_value.blank?

    separator = base_path.include?("?") ? "&" : "?"
    "#{base_path}#{separator}return_to=#{CGI.escape(return_to_value)}"
  end

  def vanity_return_to_path
    request.env["ORIGINAL_FULLPATH"].presence || request.fullpath
  end

  def normalized_flash_message(raw)
    message = raw.to_s.strip
    return "" if message.blank?
    return "" if message == "#"
    return "" if message.start_with?("#<")

    message
  end

  def current_blog_ban
    return nil unless current_user

    @current_blog_ban ||= BlogBan.active.find_by(blog_owner: @blog_owner, user: current_user)
  end

  def serialize_current_user
    return nil unless current_user

    {
      "id" => current_user.id,
      "username" => current_user.username,
      "name" => current_user.full_name,
      "email" => current_user.email,
      "confirmed" => current_user.confirmed?,
      "avatar_url" => current_user.avatar&.url
    }
  end

  def show_dashboard_link?
    return false unless current_user
    return true if current_user == @blog_owner

    current_user.can_edit?(@blog_owner)
  end

  def active_theme_slug
    user_theme = @blog_owner.user_themes.active.includes(:theme).first
    user_theme&.theme&.slug || "default"
  end

  def blog_posts
    @blog_owner.posts.published.kept.includes(:category, :tags).recent
  end

  def blog_videos
    @blog_owner.videos.published.kept.includes(:category, :tags).recent
  end

  # Returns the "top" record from a blog scope — i.e. the single item the
  # author explicitly pinned as Top from the dashboard
  # (Publishable#toggle_pinned!). Pinning is single-select per content type
  # per author, so `.first` is enough: there can only be one `featured: true`
  # record at a time. Returns nil when nothing is pinned, in which case the
  # homepage column renders an empty state instead of guessing for the user.
  def pick_top(scope)
    scope.where(featured: true).first
  end

  # Returns `scope` with `record` excluded, or the unchanged scope when
  # `record` is nil. Used so that the "latest" slot doesn't duplicate the
  # item already shown in the "top" slot.
  def exclude_record(scope, record)
    record ? scope.where.not(id: record.id) : scope
  end

  # Picks the most recent record from `scope`, preferring one that is NOT
  # the given `top` record (so the headline tile and the second-row Latest
  # tile don't duplicate). Falls back to `top` itself when it's the only
  # thing the author has -- showing the same single photo twice is still
  # better UX than rendering an empty "Latest" column on a blog that
  # genuinely only has one photo.
  def pick_latest(scope, top)
    exclude_record(scope, top).first || top
  end

  def apply_video_filters(scope, query:, years:, tags:)
    filtered = scope

    if query.present?
      filtered = filter_by_i18n_title(filtered, query: query)
    end

    years = Array(years).map(&:to_s).reject(&:blank?)
    if years.present?
      filtered = filtered.where("EXTRACT(YEAR FROM COALESCE(videos.published_at, videos.created_at))::integer IN (?)", years.map(&:to_i))
    end

    tags = Array(tags).map(&:to_s).reject(&:blank?)
    if tags.present?
      filtered = filtered.joins(:tags).where(tags: { name: tags }).distinct
    end

    filtered
  end

  def apply_post_filters(scope, query:, years:, tags:)
    filtered = scope

    if query.present?
      filtered = filter_by_i18n_title(filtered, query: query)
    end

    years = Array(years).map(&:to_s).reject(&:blank?)
    if years.present?
      filtered = filtered.where("EXTRACT(YEAR FROM COALESCE(posts.published_at, posts.created_at))::integer IN (?)", years.map(&:to_i))
    end

    tags = Array(tags).map(&:to_s).reject(&:blank?)
    if tags.present?
      filtered = filtered.joins(:tags).where(tags: { name: tags }).distinct
    end

    filtered
  end

  def apply_photo_filters(scope, query:, years:, tags:)
    filtered = scope

    if query.present?
      filtered = filter_by_i18n_title(filtered, query: query)
    end

    years = Array(years).map(&:to_s).reject(&:blank?)
    if years.present?
      filtered = filtered.where("EXTRACT(YEAR FROM COALESCE(albums.published_at, albums.created_at))::integer IN (?)", years.map(&:to_i))
    end

    tags = Array(tags).map(&:to_s).reject(&:blank?)
    if tags.present?
      filtered = filtered.joins(:tags).where(tags: { name: tags }).distinct
    end

    filtered
  end

  def filters_query_string(query:, years:, tags:)
    params = []
    params << "q=#{CGI.escape(query.to_s)}" if query.present?
    Array(years).each { |year| params << "year=#{CGI.escape(year.to_s)}" }
    Array(tags).each { |tag| params << "tag=#{CGI.escape(tag.to_s)}" }
    params.empty? ? "" : "&#{params.join('&')}"
  end

  # Delegates to the shared `TitleSearchable#search_by_title` scope on
  # Post / Video / Photo. Kept as a thin wrapper because callers pass
  # `query:` explicitly and we want the existing keyword-arg call sites
  # (`apply_post_filters` etc.) to keep working.
  def filter_by_i18n_title(scope, query:)
    return scope unless scope.respond_to?(:search_by_title)

    scope.search_by_title(query)
  end

  def blog_video_years
    @blog_video_years ||= @blog_owner.videos.published.kept
                                   .where("COALESCE(published_at, created_at) IS NOT NULL")
                                   .pluck(Arel.sql("DISTINCT EXTRACT(YEAR FROM COALESCE(published_at, created_at))::integer"))
                                   .compact
                                   .sort
                                   .reverse
  end

  def blog_video_tags
    @blog_video_tags ||= Tag.joins(:taggings)
                            .where(taggings: { taggable_type: "Video", taggable_id: @blog_owner.videos.published.kept.select(:id) })
                            .select(:name, :slug)
                            .distinct
                            .order(:name)
                            .map { |tag| { "name" => tag.name, "slug" => tag.slug } }
  end

  def blog_post_years
    @blog_post_years ||= @blog_owner.posts.published.kept
                                .where("COALESCE(published_at, created_at) IS NOT NULL")
                                .pluck(Arel.sql("DISTINCT EXTRACT(YEAR FROM COALESCE(published_at, created_at))::integer"))
                                .compact
                                .sort
                                .reverse
  end

  def blog_post_tags
    @blog_post_tags ||= Tag.joins(:taggings)
                           .where(taggings: { taggable_type: "Post", taggable_id: @blog_owner.posts.published.kept.select(:id) })
                           .select(:name, :slug)
                           .distinct
                           .order(:name)
                           .map { |tag| { "name" => tag.name, "slug" => tag.slug } }
  end

  def blog_photo_years
    @blog_photo_years ||= @blog_owner.albums.published.kept
                                 .where("COALESCE(published_at, created_at) IS NOT NULL")
                                 .pluck(Arel.sql("DISTINCT EXTRACT(YEAR FROM COALESCE(published_at, created_at))::integer"))
                                 .compact
                                 .sort
                                 .reverse
  end

  def blog_photo_tags
    @blog_photo_tags ||= Tag.joins(:taggings)
                            .where(taggings: { taggable_type: "Album", taggable_id: @blog_owner.albums.published.kept.select(:id) })
                            .select(:name, :slug)
                            .distinct
                            .order(:name)
                            .map { |tag| { "name" => tag.name, "slug" => tag.slug } }
  end

  def blog_albums
    @blog_owner.albums.published.kept.includes(:category, :tags, :photos, :cover_photo).recent
  end

  def blog_setting(key, default = nil)
    setting = SiteSetting.find_by(key: key, user: @blog_owner) ||
              SiteSetting.find_by(key: key, user_id: nil)
    setting ? setting.typed_value : default
  end

  def site_settings_hash
    locale = I18n.locale.to_s
    settings = SiteSetting.where(user: @blog_owner).or(SiteSetting.where(user_id: nil))
    settings.each_with_object({}) do |s, hash|
      val = s.typed_value
      hash[s.key] = if val.is_a?(Hash) && val.key?(locale)
                      val[locale]
      elsif val.is_a?(Hash) && val.values.first.is_a?(String)
                      val.values.compact.first
      else
                      val
      end
    end
  end

  def serialize_blog_owner
    locale = I18n.locale.to_s
    {
      "username" => @blog_owner.username,
      "name" => @blog_owner.full_name,
      "first_name" => @blog_owner.first_name,
      "last_name" => @blog_owner.last_name,
      "bio" => (@blog_owner.bio_i18n.is_a?(Hash) ? (@blog_owner.bio_i18n[locale] || @blog_owner.bio_i18n.values.compact.first) : @blog_owner.bio_i18n.to_s),
      "avatar_url" => @blog_owner.avatar&.url
    }
  end

  def serialize_post(post, full: false)
    return nil unless post

    locale = I18n.locale.to_s
    data = {
      "id" => post.id,
      "slug" => post.slug,
      "title" => post.title_i18n[locale] || post.title_i18n.values.compact.first,
      "subtitle" => post.subtitle_i18n[locale] || post.subtitle_i18n.values.compact.first,
      "lead" => post.lead_i18n[locale] || post.lead_i18n.values.compact.first,
      "featured" => post.featured?,
      "featured_image" => post.featured_image&.url,
      "published_at" => post.published_at,
      "reading_time" => post.reading_time,
      "views_count" => post.views_count,
      "comments_count" => post.comments_count,
      "category" => post.category ? serialize_category(post.category) : nil,
      "tags" => post.tags.map { |t| { "name" => t.name, "slug" => t.slug } },
      "author" => serialize_blog_owner,
      "source_name" => post.external_source,
      "source_url" => post.try(:source_url)
    }
    if full
      data["content"] = post.content_i18n[locale] || post.content_i18n.values.compact.first
      data["comments_enabled"] = post.comments_enabled?
      data["related_video"] = serialize_video(post.video, full: false) if post.video.present?
      data["documents"] = post.documents.map { |d| serialize_document(d) }
    end
    data
  end

  def serialize_document(doc)
    {
      "id" => doc.id,
      "url" => doc.file&.url,
      "file_name" => doc.file_name,
      "title" => doc.title,
      "size" => doc.human_file_size,
      "content_type" => doc.content_type
    }
  end

  def serialize_video(video, full: false)
    return nil unless video

    locale = I18n.locale.to_s
    data = {
      "id" => video.id,
      "slug" => video.slug,
      "title" => video.title_i18n[locale] || video.title_i18n.values.compact.first,
      "subtitle" => video.subtitle_i18n[locale] || video.subtitle_i18n.values.compact.first,
      "featured" => video.featured?,
      "thumbnail_url" => blog_video_thumbnail_url(video),
      "published_at" => video.published_at,
      "views_count" => video.views_count,
      "video_provider" => video.video_provider,
      "embed_url" => video.embed_url,
      "duration" => video.duration_formatted,
      "category" => video.category ? serialize_category(video.category) : nil,
      "tags" => video.tags.map { |t| { "name" => t.name, "slug" => t.slug } }
    }
    if full
      data["description"] = video.description_i18n[locale] || video.description_i18n.values.compact.first
      data["video_url"] = video.video_url
    end
    data
  end

  def blog_video_thumbnail_url(video)
    local_url = video.thumbnail&.url.to_s
    return local_url if local_url.present?

    "/images/fallback/video_thumbnail.png"
  end

  def serialize_album(album, full: false)
    return nil unless album

    locale = I18n.locale.to_s
    cover = album.display_cover
    data = {
      "id" => album.id,
      "slug" => album.slug,
      "title" => album.title_i18n[locale] || album.title_i18n.values.compact.first,
      "description" => album.description_i18n[locale] || album.description_i18n.values.compact.first,
      "cover_image_url" => cover&.image&.url,
      "cover_thumb_url" => cover&.image&.thumb&.url || cover&.image&.url,
      "featured" => album.featured?,
      "published_at" => album.published_at,
      "views_count" => album.views_count,
      "photos_count" => album.photos_count,
      "category" => album.category ? serialize_category(album.category) : nil,
      "tags" => album.tags.map { |t| { "name" => t.name, "slug" => t.slug } }
    }
    if full
      data["photos"] = album.photos.map do |photo|
        {
          "id" => photo.id,
          "slug" => photo.slug,
          "title" => photo.title_i18n[locale] || photo.title_i18n.values.compact.first,
          "description" => photo.description_i18n[locale] || photo.description_i18n.values.compact.first,
          "alt" => photo.alt_text_i18n[locale] || photo.alt_text_i18n.values.compact.first,
          "image_url" => photo.image&.url,
          "thumb_url" => photo.image&.thumb&.url || photo.image&.url
        }
      end
    end
    data
  end

  def serialize_category(cat)
    locale = I18n.locale.to_s
    {
      "slug" => cat.slug,
      "name" => cat.name_i18n[locale] || cat.name_i18n.values.compact.first,
      "posts_count" => cat.posts_count,
      "videos_count" => cat.videos_count,
      "photos_count" => cat.photos_count
    }
  end

  def serialize_categories
    @blog_owner.categories.ordered.map { |c| serialize_category(c) }
  end

  def serialize_page(pg)
    featured_image_url = pg.featured_image_identifier.present? ? pg.featured_image&.url : nil
    {
      "slug" => pg.slug,
      "title" => localized_i18n_value(pg.title_i18n),
      "content" => localized_i18n_value(pg.content_i18n),
      "featured_image_url" => featured_image_url,
      "page_type" => pg.page_type,
      "show_in_menu" => pg.show_in_menu?
    }
  end

  def serialize_comment(comment)
    avatar_url = if comment.user&.avatar_identifier.present?
                   comment.user.avatar.url
    end

    {
      "id" => comment.id,
      "content" => comment.content,
      "author_name" => comment.author_name,
      "avatar_url" => avatar_url,
      "user_name" => comment.author_name,
      "guest_name" => comment.guest_name,
      "user" => (comment.user ? { "username" => comment.user.username, "name" => comment.user.full_name } : nil),
      "created_at" => comment.created_at,
      "replies" => comment.replies.approved.oldest.map { |r| serialize_comment(r) }
    }
  end

  def menu_pages
    @blog_owner.pages.published.in_menu.map do |pg|
      {
        "slug" => pg.slug,
        "title" => localized_i18n_value(pg.display_menu_title)
      }
    end
  end

  def nav_menu_items
    menu = BlogNavigationMenu.new(user: @blog_owner)

    menu.items.filter_map do |item|
      next unless item[:visible]

      title = if item[:kind] == "static"
                i18n_theme_translation("navigation.#{item[:navigation_key]}", default: item[:navigation_key].to_s.humanize)
      else
                page = item[:page]
                next if page.blank?

                localized_i18n_value(page.display_menu_title)
      end

      {
        "id" => item[:id],
        "title" => title,
        "url" => navigation_item_url(item)
      }
    end
  end

  def navigation_item_url(item)
    base = vanity_request? ? "" : "/blogs/#{@blog_owner.username}"

    if item[:kind] == "static"
      case item[:id]
      when "home" then base.presence || "/"
      when "about" then "#{base}/pages/about"
      when "videos" then "#{base}/videos"
      when "posts" then "#{base}/posts"
      when "gallery" then "#{base}/gallery"
      else base.presence || "/"
      end
    else
      "#{base}/pages/#{item[:slug]}"
    end
  end

  # Reads translated values with resilient fallback. Empty strings should not
  # win over existing translations (e.g. pl="" should fall back to uk content).
  def localized_i18n_value(value)
    return value.to_s unless value.is_a?(Hash)

    locale = I18n.locale.to_s
    canonical_locale = LocaleTags.canonical_locale_code(locale).to_s
    default_locale = LocaleTags.canonical_locale_code(blog_setting("default_locale", "")).to_s
    fallback_locale = blog_locale_fallback(blog_available_locales).to_s
    candidates = [ locale, canonical_locale, default_locale, fallback_locale ].compact.reject(&:blank?).uniq

    candidates.each do |code|
      translated = value[code].presence
      return translated if translated.present?
    end

    value.values.find(&:present?).to_s
  end

  def popular_tags
    Tag.popular.limit(15).map { |t| { "name" => t.name, "slug" => t.slug, "count" => t.taggings_count } }
  end

  def serialize_partners
    locale = I18n.locale.to_s
    Partner.active.ordered.for_user(@blog_owner).where.not(logo_svg: [ nil, "" ]).map do |p|
      desc = p.description_i18n.is_a?(Hash) ? (p.description_i18n[locale] || p.description_i18n.values.compact.first) : p.description_i18n.to_s
      {
        "name" => p.name,
        "slug" => p.slug,
        "url" => p.url,
        "logo_svg" => p.logo_svg,
        "logo_url" => p.logo_url,
        "description" => desc,
        "position" => p.position
      }
    end
  end

  def blog_available_locales
    @blog_available_locales ||= SiteSetting.blog_available_locale_codes_for(@blog_owner)
  end

  def blog_locale_switcher_items
    blog_available_locales.map do |code|
      {
        "canonical" => code,
        "path_segment" => LocaleTags.path_segment_for_canonical(code),
        "ui_tag" => LocaleTags.ui_tag(code),
        "native_name" => LocaleTags.native_name(code)
      }
    end
  end

  def blog_locale_fallback(allowed)
    return allowed.first if allowed.blank?

    allowed.include?("en") ? "en" : allowed.first
  end
end
