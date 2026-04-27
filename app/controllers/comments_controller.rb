# frozen_string_literal: true

# Public-facing comments controller. Anonymous and unconfirmed users are not
# allowed to post comments — they get a 403 with a hint to sign up / confirm.
# Confirmed signed-in comments are auto-approved.
class CommentsController < ApplicationController
  MAX_COMMENT_DEPTH = 2

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # Devise's Confirmable runs in Warden's `after_set_user` callback and will
  # automatically log out (and redirect to /users/sign_in) any unconfirmed
  # user before our before_actions even run, so a single `authenticate_user!`
  # covers both anonymous and unconfirmed cases here.
  before_action :authenticate_user!
  before_action :set_blog_owner
  before_action :set_commentable
  before_action :ensure_not_banned_for_blog!

  def create
    if @commentable.respond_to?(:comments_enabled) && @commentable.comments_enabled == false
      flash[:blog_alert] = t("comments.disabled", default: "Comments are disabled for this post.")
      redirect_back fallback_location: commentable_redirect_path and return
    end

    parent = @commentable.comments.find_by(id: params[:parent_id]) if params[:parent_id].present?
    parent = normalized_parent(parent)

    comment = @commentable.comments.build(comment_params)
    comment.user = current_user
    comment.parent = parent if parent
    if auto_approve_comment_for?(current_user)
      comment.status = "approved"
      comment.approved_at = Time.current
      comment.approved_by = current_user
    else
      comment.status = "pending"
    end
    comment.ip_address = request.remote_ip
    comment.user_agent = request.user_agent

    if comment.save
      flash[:blog_notice] = if comment.approved?
                         t("comments.posted", default: "Thanks for your comment.")
      else
                         t("comments.pending_approval", default: "Your comment is awaiting moderation.")
      end
    else
      flash[:blog_alert] = comment.errors.full_messages.to_sentence
    end

    redirect_to commentable_redirect_path
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def set_blog_owner
    @blog_owner = User.active.find_by!(username: params[:blog_slug])
  end

  def set_commentable
    if params[:post_slug].present?
      @commentable = @blog_owner.posts.published.kept.find_by!(slug: params[:post_slug])
    elsif params[:video_slug].present?
      @commentable = @blog_owner.videos.published.kept.find_by!(slug: params[:video_slug])
    elsif params[:album_slug].present?
      @commentable = @blog_owner.albums.published.kept.find_by!(slug: params[:album_slug])
    else
      raise ActiveRecord::RecordNotFound, "Commentable not found"
    end
  end

  def ensure_not_banned_for_blog!
    return unless current_user&.banned_from_blog?(@blog_owner)

    flash[:blog_alert] = t("comments.banned_from_blog", default: "You are permanently banned from this blog.")
    redirect_to commentable_redirect_path
  end

  def auto_approve_comment_for?(user)
    return true if user == @blog_owner
    return true if user.trusted_for_blog_comments?(@blog_owner)

    !comments_premoderation_enabled?
  end

  def comments_premoderation_enabled?
    ActiveModel::Type::Boolean.new.cast(
      SiteSetting.get("comments_premoderation_enabled", user: @blog_owner, default: true)
    )
  end


  def commentable_redirect_path
    slug = @commentable.slug

    if request.env["ORIGINAL_HOST"].present?
      if @commentable.is_a?(Post)
        "/posts/#{slug}"
      elsif @commentable.is_a?(Video)
        "/videos/#{slug}"
      else
        "/gallery/#{slug}"
      end
    else
      if @commentable.is_a?(Post)
        blog_post_path(blog_slug: @blog_owner.username, slug: slug)
      elsif @commentable.is_a?(Video)
        blog_video_path(blog_slug: @blog_owner.username, slug: slug)
      else
        blog_album_path(blog_slug: @blog_owner.username, slug: slug)
      end
    end
  end

  def normalized_parent(parent)
    return nil unless parent

    # Keep nesting visually readable: max 3 levels total (depth 0..2).
    while parent.depth >= MAX_COMMENT_DEPTH && parent.parent.present?
      parent = parent.parent
    end

    parent
  end
end
