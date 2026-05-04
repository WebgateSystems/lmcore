# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BlogNewsletterSubscriptions", type: :request do
  let!(:blog_owner) { create(:user, username: "owner_newsletter") }
  let!(:subscriber) { create(:user, email: "subscriber@example.com") }

  describe "POST /blogs/:blog_slug/newsletter_subscriptions" do
    it "requires authentication" do
      post blog_newsletter_subscriptions_path(blog_slug: blog_owner.username)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates subscription for current user email" do
      sign_in subscriber

      expect do
        post blog_newsletter_subscriptions_path(blog_slug: blog_owner.username), params: {
          return_to: "/blogs/#{blog_owner.username}/videos"
        }
      end.to change(NewsletterSubscription, :count).by(1)

      expect(response).to redirect_to("/blogs/#{blog_owner.username}/videos")
      record = NewsletterSubscription.order(:created_at).last
      expect(record.blog_owner).to eq(blog_owner)
      expect(record.user).to eq(subscriber)
      expect(record.email).to eq(subscriber.email)
    end

    it "shows the themed success flash only on the redirected render" do
      sign_in subscriber
      message = I18n.t("themes.am.newsletter.subscribed", default: "Zapisano do newslettera.")

      post blog_newsletter_subscriptions_path(blog_slug: blog_owner.username)
      follow_redirect!

      expect(response.body).to include(message)

      get blog_path(blog_slug: blog_owner.username)

      expect(response.body).not_to include(message)
    end

    it "does not duplicate existing subscription for same blog and email" do
      sign_in subscriber
      create(:newsletter_subscription, blog_owner: blog_owner, user: subscriber, email: subscriber.email)

      expect do
        post blog_newsletter_subscriptions_path(blog_slug: blog_owner.username)
      end.not_to change(NewsletterSubscription, :count)

      expect(response).to redirect_to(blog_path(blog_slug: blog_owner.username))
      expect(flash[:notice]).to include("text", "token")
      expect(flash[:notice]["text"]).to eq(I18n.t("themes.am.newsletter.subscribed", default: "Zapisano do newslettera."))
      expect(flash[:notice]["token"]).to be_present
    end

    it "blocks banned users from subscribing" do
      sign_in subscriber
      create(:blog_ban, blog_owner: blog_owner, user: subscriber, banned_by: blog_owner, active: true, permanent: true)

      expect do
        post blog_newsletter_subscriptions_path(blog_slug: blog_owner.username)
      end.not_to change(NewsletterSubscription, :count)

      expect(response).to redirect_to(blog_path(blog_slug: blog_owner.username))
      expect(flash[:alert]).to include("text", "token")
      expect(flash[:alert]["text"]).to be_present
      expect(flash[:alert]["token"]).to be_present
    end
  end
end
