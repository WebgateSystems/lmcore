# frozen_string_literal: true

module Admin
  class PostsController < BaseController
    before_action :set_post, only: %i[show edit update destroy publish unpublish feature]

    def index
      authorize Post, policy_class: Admin::PostPolicy

      posts = policy_scope(Post, policy_scope_class: Admin::PostPolicy::Scope)
              .includes(:author, :category)
              .order(sort_column => sort_direction)

      # Apply filters
      posts = posts.where(status: params[:status]) if params[:status].present?
      posts = posts.where(author_id: params[:author_id]) if params[:author_id].present?
      posts = posts.where("title_i18n::text ILIKE :q OR content_i18n::text ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @posts = pagy(posts, items: params[:per_page] || 25)
      @authors = User.joins(:posts).distinct.order(:username)
    end

    def show
      authorize @post, policy_class: Admin::PostPolicy
    end

    def new
      @post = Post.new
      authorize @post, policy_class: Admin::PostPolicy
      @categories = Category.all
    end

    def create
      @post = Post.new(post_params)
      @post.author = current_user
      authorize @post, policy_class: Admin::PostPolicy

      if @post.save
        log_action("create", @post)
        redirect_to admin_post_path(@post), notice: "Post created successfully."
      else
        @categories = Category.all
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @post, policy_class: Admin::PostPolicy
      @categories = Category.all
    end

    def update
      authorize @post, policy_class: Admin::PostPolicy

      if @post.update(post_params)
        log_action("update", @post)
        redirect_to admin_post_path(@post), notice: "Post updated successfully."
      else
        @categories = Category.all
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @post, policy_class: Admin::PostPolicy

      @post.destroy
      log_action("delete", @post)
      redirect_to admin_posts_path, notice: "Post deleted successfully."
    end

    def publish
      authorize @post, policy_class: Admin::PostPolicy

      if @post.publish!
        log_action("publish", @post)
        redirect_to admin_post_path(@post), notice: "Post published successfully."
      else
        redirect_to admin_post_path(@post), alert: "Failed to publish post."
      end
    end

    def unpublish
      authorize @post, policy_class: Admin::PostPolicy

      if @post.unpublish!
        log_action("unpublish", @post)
        redirect_to admin_post_path(@post), notice: "Post unpublished."
      else
        redirect_to admin_post_path(@post), alert: "Failed to unpublish post."
      end
    end

    def feature
      authorize @post, policy_class: Admin::PostPolicy

      @post.update(featured: !@post.featured?)
      action = @post.featured? ? "feature" : "unfeature"
      log_action(action, @post)
      redirect_to admin_post_path(@post), notice: "Post #{action}d successfully."
    end

    private

    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(
        :status, :featured, :published_at, :category_id,
        :featured_image, :og_image,
        title_i18n: {}, subtitle_i18n: {}, lead_i18n: {}, content_i18n: {},
        keywords_i18n: {}, meta_description_i18n: {}
      )
    end

    def sort_column
      Post.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def log_action(action, post, details = {})
      AuditLog.create!(
        user: current_user,
        action: action,
        auditable: post,
        metadata: details.merge(post_title: post.title),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_id: request.request_id
      )
    end
  end
end
