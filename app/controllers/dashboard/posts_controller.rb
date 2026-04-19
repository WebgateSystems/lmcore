# frozen_string_literal: true

module Dashboard
  class PostsController < BaseController
    before_action :set_post, only: %i[show edit update destroy]

    def index
      authorize Post, policy_class: Dashboard::PostPolicy
      posts = policy_scope(Post, policy_scope_class: Dashboard::PostPolicy::Scope)
              .order(created_at: :desc)
      posts = posts.where(status: params[:status]) if params[:status].present?
      @pagy, @posts = pagy(posts, items: 20)
    end

    def show
      authorize @post, policy_class: Dashboard::PostPolicy
      redirect_to edit_dashboard_post_path(@post)
    end

    def new
      @post = Post.new
      authorize @post, policy_class: Dashboard::PostPolicy
      @categories = scoped_categories
    end

    def create
      @post = Post.new(post_params)
      @post.author = current_user
      authorize @post, policy_class: Dashboard::PostPolicy

      if @post.save
        attach_pending_attachments(@post)
        redirect_to edit_dashboard_post_path(@post), notice: t("dashboard.flash.posts.created")
      else
        @categories = scoped_categories
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @post, policy_class: Dashboard::PostPolicy
      @categories = scoped_categories
    end

    def update
      authorize @post, policy_class: Dashboard::PostPolicy
      if @post.update(post_params)
        attach_pending_attachments(@post)
        redirect_to edit_dashboard_post_path(@post), notice: t("dashboard.flash.posts.updated")
      else
        @categories = scoped_categories
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @post, policy_class: Dashboard::PostPolicy
      @post.destroy!
      redirect_to dashboard_posts_path, notice: t("dashboard.flash.posts.trashed")
    end

    private

    def set_post
      @post = scoped_posts.find(params[:id])
    end

    def post_params
      params.require(:post).permit(
        :slug, :status, :category_id, :featured_image, :published_at, :featured,
        :content_format, :comments_enabled,
        title_i18n: {},
        subtitle_i18n: {},
        lead_i18n: {},
        content_i18n: {},
        content_source_i18n: {},
        meta_description_i18n: {},
        keywords_i18n: {},
        tag_ids: []
      )
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
