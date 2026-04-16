# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :set_blog_owner
  before_action :set_theme_renderer
  before_action :set_locale_from_blog

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    featured_post = blog_posts.where(featured: true).first
    recent_posts = blog_posts.where(featured: false).limit(6)
    recent_videos = blog_videos.limit(4)
    recent_photos = blog_photos.limit(6)

    render_theme("index",
      featured_post: serialize_post(featured_post),
      posts: recent_posts.map { |p| serialize_post(p) },
      videos: recent_videos.map { |v| serialize_video(v) },
      photos: recent_photos.map { |p| serialize_photo(p) },
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

    render_theme("videos/show",
      video: serialize_video(vid, full: true),
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
      categories: serialize_categories,
      years: blog_video_years,
      tags: blog_video_tags,
      query: query,
      selected_years: selected_years,
      selected_tags: selected_tags,
      filters_query: filters_query_string(query: query, years: selected_years, tags: selected_tags))
  end

  def photo
    ph = blog_photos.find_by!(slug: params[:slug])
    ph.increment_views!

    render_theme("photos/show",
      photo: serialize_photo(ph, full: true),
      categories: serialize_categories)
  end

  def photos
    query = params[:q].to_s.strip
    selected_years = Array(params[:year]).reject(&:blank?)
    selected_tags = Array(params[:tag]).reject(&:blank?)
    page = (params[:page] || 1).to_i
    per_page = 12
    filtered_photos = apply_photo_filters(
      blog_photos,
      query: query,
      years: selected_years,
      tags: selected_tags
    )
    all_photos = filtered_photos.offset((page - 1) * per_page).limit(per_page)
    total = filtered_photos.count

    render_theme("photos/index",
      photos: all_photos.map { |p| serialize_photo(p) },
      pagination: { current_page: page, per_page: per_page, total: total, total_pages: (total.to_f / per_page).ceil },
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
    redirect_to blog_path(blog_slug: @blog_owner.username)
  end

  private

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

  def common_assigns
    {
      "site" => site_settings_hash,
      "blog" => serialize_blog_owner,
      "locale" => I18n.locale.to_s,
      "base_path" => "/blogs/#{@blog_owner.username}",
      "theme_slug" => active_theme_slug,
      "theme_translation_scope" => "themes.#{active_theme_slug}",
      "current_url" => request.original_url,
      "pages_menu" => menu_pages,
      "partners" => serialize_partners,
      "available_locales" => blog_available_locales,
      "locale_display" => LocaleTags.ui_tag(I18n.locale),
      "blog_locale_switcher_items" => blog_locale_switcher_items,
      "popular_tags" => popular_tags
    }
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
      filtered = filtered.where("EXTRACT(YEAR FROM COALESCE(photos.published_at, photos.created_at))::integer IN (?)", years.map(&:to_i))
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

  def filter_by_i18n_title(scope, query:)
    q = query.to_s
    patterns = [
      q,
      q.downcase,
      q.upcase,
      q.capitalize
    ].map { |v| "%#{ActiveRecord::Base.sanitize_sql_like(v)}%" }
    case scope.table_name
    when "posts"
      scope.where(
        "EXISTS (SELECT 1 FROM jsonb_each_text(posts.title_i18n) AS title(locale, value) WHERE title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ?)",
        *patterns
      )
    when "videos"
      scope.where(
        "EXISTS (SELECT 1 FROM jsonb_each_text(videos.title_i18n) AS title(locale, value) WHERE title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ?)",
        *patterns
      )
    when "photos"
      scope.where(
        "EXISTS (SELECT 1 FROM jsonb_each_text(photos.title_i18n) AS title(locale, value) WHERE title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ?)",
        *patterns
      )
    else
      scope
    end
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
    @blog_photo_years ||= @blog_owner.photos.published.kept
                                 .where("COALESCE(published_at, created_at) IS NOT NULL")
                                 .pluck(Arel.sql("DISTINCT EXTRACT(YEAR FROM COALESCE(published_at, created_at))::integer"))
                                 .compact
                                 .sort
                                 .reverse
  end

  def blog_photo_tags
    @blog_photo_tags ||= Tag.joins(:taggings)
                            .where(taggings: { taggable_type: "Photo", taggable_id: @blog_owner.photos.published.kept.select(:id) })
                            .select(:name, :slug)
                            .distinct
                            .order(:name)
                            .map { |tag| { "name" => tag.name, "slug" => tag.slug } }
  end

  def blog_photos
    @blog_owner.photos.published.kept.includes(:category, :tags).recent
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
      "source_name" => post.external_source
    }
    if full
      data["content"] = post.content_i18n[locale] || post.content_i18n.values.compact.first
      data["comments_enabled"] = post.comments_enabled?
      data["related_video"] = serialize_video(post.video, full: false) if post.video.present?
    end
    data
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

  def serialize_photo(photo, full: false)
    return nil unless photo

    locale = I18n.locale.to_s
    {
      "id" => photo.id,
      "slug" => photo.slug,
      "title" => photo.title_i18n[locale] || photo.title_i18n.values.compact.first,
      "description" => photo.description_i18n[locale] || photo.description_i18n.values.compact.first,
      "image_url" => photo.image&.url,
      "featured" => photo.featured?,
      "published_at" => photo.published_at,
      "views_count" => photo.views_count,
      "category" => photo.category ? serialize_category(photo.category) : nil,
      "tags" => photo.tags.map { |t| { "name" => t.name, "slug" => t.slug } }
    }
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
    locale = I18n.locale.to_s
    {
      "slug" => pg.slug,
      "title" => pg.title_i18n[locale] || pg.title_i18n.values.compact.first,
      "content" => pg.content_i18n[locale] || pg.content_i18n.values.compact.first,
      "page_type" => pg.page_type,
      "show_in_menu" => pg.show_in_menu?
    }
  end

  def serialize_comment(comment)
    {
      "id" => comment.id,
      "content" => comment.content,
      "author_name" => comment.author_name,
      "created_at" => comment.created_at,
      "replies" => comment.replies.approved.oldest.map { |r| serialize_comment(r) }
    }
  end

  def menu_pages
    @blog_owner.pages.published.in_menu.map do |pg|
      locale = I18n.locale.to_s
      {
        "slug" => pg.slug,
        "title" => pg.display_menu_title.is_a?(Hash) ? (pg.display_menu_title[locale] || pg.display_menu_title.values.compact.first) : pg.display_menu_title.to_s
      }
    end
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
