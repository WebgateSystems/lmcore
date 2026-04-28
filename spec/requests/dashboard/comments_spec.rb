# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Comments", type: :request do
  describe "as an author moderating their own blog" do
    let(:author) { create(:user, :author) }
    let(:my_post) { create(:post, author: author) }
    let(:commenting_user) { create(:user) }
    let!(:my_comment) { create(:comment, user: commenting_user, commentable: my_post) }

    before { sign_in author }

    it "lists comments left under the author's content" do
      get dashboard_comments_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(my_comment.content[0, 30])
    end

    it "approves a comment on own content" do
      patch dashboard_comment_path(my_comment), params: { comment: { status: "approved" } }
      expect(response).to redirect_to(dashboard_comments_path)
      expect(my_comment.reload.status).to eq("approved")
    end

    it "discards a comment on own content" do
      delete dashboard_comment_path(my_comment)
      expect(response).to redirect_to(dashboard_comments_path)
      expect(my_comment.reload.status).to eq("deleted")
      expect(my_comment.discarded?).to be true

      get dashboard_comments_path
      expect(response.body).not_to include(my_comment.content[0, 30])
    end
  end

  describe "siloing across blogs (dashboard is per-blog, even for moderators)" do
    let(:moderator) { create(:user, :moderator) }
    let(:other_post) { create(:post) }
    let!(:foreign_comment) { create(:comment, commentable: other_post) }

    before { sign_in moderator }

    it "does not list comments from other people's blogs" do
      get dashboard_comments_path
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(foreign_comment.content[0, 30])
    end

    it "404s when trying to moderate a comment from another blog" do
      patch dashboard_comment_path(foreign_comment), params: { comment: { status: "approved" } }
      expect(response).to have_http_status(:not_found)
      expect(foreign_comment.reload.status).to eq("pending")
    end
  end
end
