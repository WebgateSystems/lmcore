# frozen_string_literal: true

module Dashboard
  class PostsController < BaseController
    before_action :set_post, only: %i[show edit update destroy pin]

    def index
      authorize Post, policy_class: Dashboard::PostPolicy
      posts = policy_scope(Post, policy_scope_class: Dashboard::PostPolicy::Scope)
              .order(Arel.sql("COALESCE(published_at, created_at) DESC"))
      posts = posts.where(status: params[:status]) if params[:status].present?
      posts = posts.search_by_title(params[:q]) if params[:q].present?
      @pagy, @posts = pagy(posts, items: 20)
    end

    def show
      authorize @post, policy_class: Dashboard::PostPolicy
      redirect_to edit_dashboard_post_path(@post)
    end

    def new
      @post = Post.new
      authorize @post, policy_class: Dashboard::PostPolicy
      load_form_collections
    end

    def create
      @post = Post.new(post_params)
      @post.author = dashboard_blog_user
      authorize @post, policy_class: Dashboard::PostPolicy

      if @post.save
        attach_pending_attachments(@post)
        redirect_to edit_dashboard_post_path(@post), notice: t("dashboard.flash.posts.created")
      else
        load_form_collections
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @post, policy_class: Dashboard::PostPolicy
      load_form_collections
    end

    def update
      authorize @post, policy_class: Dashboard::PostPolicy
      if @post.update(post_params)
        attach_pending_attachments(@post)
        redirect_to edit_dashboard_post_path(@post), notice: t("dashboard.flash.posts.updated")
      else
        load_form_collections
        render :edit, status: :unprocessable_entity
      end
    end

    # Hard-deletes the post, cascading comments + replies, reactions,
    # taggings, content visibilities, and media attachments (which removes
    # the underlying CarrierWave files). Linked Pravda imports continue to
    # work after a hard delete — `Pravda::AuthorBlogImportService` does a
    # `with_discarded.find_or_initialize_by(...)` which simply falls
    # through to "initialize new" when the row is gone, so the next import
    # creates a fresh record. The dashboard guards this with a
    # confirmation modal — see `data-confirm-destroy` in
    # app/views/dashboard/posts/index.html.slim.
    def destroy
      authorize @post, policy_class: Dashboard::PostPolicy
      @post.destroy!
      redirect_to dashboard_posts_path, notice: t("dashboard.flash.posts.deleted")
    end

    # Toggles this post as the single "Top article" on the public homepage
    # for the current author. See Publishable#toggle_pinned!.
    def pin
      authorize @post, policy_class: Dashboard::PostPolicy
      pinned = @post.toggle_pinned!
      flash_key = pinned ? "dashboard.flash.posts.pinned" : "dashboard.flash.posts.unpinned"
      redirect_back fallback_location: dashboard_posts_path, notice: t(flash_key)
    end

    private

    def set_post
      @post = scoped_posts.find(params[:id])
    end

    def post_params
      permitted = params.require(:post).permit(
        :slug, :status, :category_id, :featured_image, :published_at, :featured,
        :content_format, :comments_enabled, :video_id, :source_name, :source_url, :related_video_url,
        title_i18n: {},
        subtitle_i18n: {},
        lead_i18n: {},
        content_i18n: {},
        content_source_i18n: {},
        meta_description_i18n: {},
        keywords_i18n: {},
        tag_ids: []
      )
      permitted[:video_id] = nil if permitted.key?(:related_video_url)
      permitted
    end

    def load_form_collections
      @categories = scoped_categories
      @available_tags = policy_scope(Tag, policy_scope_class: Dashboard::TagPolicy::Scope).alphabetical
    end

    # Links MediaAttachments uploaded as orphans (no attachable_id) by the
    # current user and explicitly listed via hidden inputs in the form
    # (`pending_attachment_ids[]`). The current user must own each attachment.
    def attach_pending_attachments(post)
      ids = Array(params[:pending_attachment_ids]).reject(&:blank?)
      return if ids.empty?

      MediaAttachment
        .where(id: ids, user_id: current_user.id, attachable_id: nil)
        .update_all(attachable_type: "Post", attachable_id: post.id)
    end
  end
end
