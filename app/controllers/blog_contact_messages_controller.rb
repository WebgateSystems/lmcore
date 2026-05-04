# frozen_string_literal: true

class BlogContactMessagesController < ApplicationController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :authenticate_user!
  before_action :set_blog_owner
  before_action :ensure_not_banned_for_blog!

  def create
    message = ContactMessage.new(contact_message_params)
    message.user = current_user
    message.blog_owner = @blog_owner
    message.name = current_user.full_name if message.name.blank?
    message.email = current_user.email if message.email.blank?

    if message.save
      set_blog_flash(:notice, t("themes.am.contact.sent", default: "Wiadomosc zostala wyslana."))
    else
      set_blog_flash(:alert, message.errors.full_messages.to_sentence)
    end

    redirect_to return_path
  end

  private

  def set_blog_owner
    @blog_owner = User.active.find_by!(username: params[:blog_slug])
  end

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :message)
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

    set_blog_flash(:alert, t("themes.am.comments.banned_from_blog", default: "You are permanently banned from this blog."))
    redirect_to return_path
  end
end
