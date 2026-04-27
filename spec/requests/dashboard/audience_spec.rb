# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Audience", type: :request do
  let(:author) { create(:user, :author) }
  let(:commenter) { create(:user, email: "commenter@example.com") }
  let(:subscriber) { create(:user, email: "subscriber@example.com") }
  let(:post_record) { create(:post, author: author, status: "published", published_at: 1.day.ago) }

  before do
    sign_in author
    create(:comment, user: commenter, commentable: post_record, status: "approved")
    create(:newsletter_subscription, blog_owner: author, user: subscriber)
  end

  describe "GET /dashboard/audience" do
    it "renders commenters and newsletter subscribers" do
      get dashboard_audience_index_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(commenter.email)
      expect(response.body).to include(subscriber.email)
    end

    it "filters by search query" do
      get dashboard_audience_index_path, params: { q: "subscriber@" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(subscriber.email)
      expect(response.body).not_to include(commenter.email)
    end
  end

  describe "POST /dashboard/audience/ban" do
    it "creates a permanent ban with reason for this blog" do
      expect {
        post ban_dashboard_audience_index_path, params: { user_id: commenter.id, reason: "spam links" }
      }.to change(BlogBan, :count).by(1)

      ban = BlogBan.last
      expect(ban.blog_owner).to eq(author)
      expect(ban.user).to eq(commenter)
      expect(ban.reason).to eq("spam links")
      expect(ban.permanent).to be(true)
      expect(response).to redirect_to(dashboard_audience_index_path)
    end
  end

  describe "trusted commenters" do
    it "grants trusted commenter permission" do
      expect {
        post trust_dashboard_audience_index_path, params: { user_id: commenter.id }
      }.to change(BlogTrustedCommenter, :count).by(1)

      expect(response).to redirect_to(dashboard_audience_index_path)
    end

    it "revokes trusted commenter permission" do
      create(:blog_trusted_commenter, blog_owner: author, user: commenter, granted_by: author)

      expect {
        delete untrust_dashboard_audience_index_path, params: { user_id: commenter.id }
      }.to change(BlogTrustedCommenter, :count).by(-1)

      expect(response).to redirect_to(dashboard_audience_index_path)
    end
  end
end
