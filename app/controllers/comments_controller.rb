# frozen_string_literal: true

# Public-facing comments controller. Anonymous and unconfirmed users are not
# allowed to post comments — they get a 403 with a hint to sign up / confirm.
# Confirmed signed-in comments are auto-approved.
class CommentsController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  # Devise's Confirmable runs in Warden's `after_set_user` callback and will
  # automatically log out (and redirect to /users/sign_in) any unconfirmed
  # user before our before_actions even run, so a single `authenticate_user!`
  # covers both anonymous and unconfirmed cases here.
  before_action :authenticate_user!
  before_action :set_blog_owner
  before_action :set_post

  def create
    if @post.comments_enabled == false
      flash[:alert] = t("comments.disabled", default: "Comments are disabled for this post.")
      redirect_back fallback_location: post_redirect_path and return
    end

    parent = @post.comments.find_by(id: params[:parent_id]) if params[:parent_id].present?

    comment = @post.comments.build(comment_params)
    comment.user = current_user
    comment.parent = parent if parent
    comment.status = "approved"
    comment.approved_at = Time.current
    comment.approved_by = current_user
    comment.ip_address = request.remote_ip
    comment.user_agent = request.user_agent

    if comment.save
      flash[:notice] = t("comments.posted", default: "Thanks for your comment.")
    else
      flash[:alert] = comment.errors.full_messages.to_sentence
    end

    redirect_to post_redirect_path
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def set_blog_owner
    @blog_owner = User.active.find_by!(username: params[:blog_slug])
  end

  def set_post
    @post = @blog_owner.posts.published.kept.find_by!(slug: params[:post_slug])
  end


  def post_redirect_path
    if request.env["ORIGINAL_HOST"].present?
      "/posts/#{@post.slug}"
    else
      blog_post_path(blog_slug: @blog_owner.username, slug: @post.slug)
    end
  end
end
