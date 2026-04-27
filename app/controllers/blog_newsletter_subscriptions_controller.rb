# frozen_string_literal: true

class BlogNewsletterSubscriptionsController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :authenticate_user!
  before_action :set_blog_owner
  before_action :ensure_not_banned_for_blog!

  def create
    subscription = NewsletterSubscription.find_or_initialize_by(
      blog_owner: @blog_owner,
      email: current_user.email
    )
    subscription.user = current_user

    if subscription.save
      flash[:blog_notice] = t("themes.am.newsletter.subscribed", default: "Zapisano do newslettera.")
    else
      flash[:blog_alert] = subscription.errors.full_messages.to_sentence
    end

    redirect_to return_path
  end

  private

  def set_blog_owner
    @blog_owner = User.active.find_by!(username: params[:blog_slug])
  end

  def return_path
    candidate = params[:return_to].to_s
    if candidate.start_with?("/") && !candidate.start_with?("//")
      candidate
    else
      blog_path(blog_slug: @blog_owner.username)
    end
  end

  def ensure_not_banned_for_blog!
    return unless current_user&.banned_from_blog?(@blog_owner)

    flash[:blog_alert] = t("themes.am.comments.banned_from_blog", default: "You are permanently banned from this blog.")
    redirect_to return_path
  end
end
