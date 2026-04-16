# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Comments", type: :request do
  describe "as an author (non-moderator)" do
    let(:author) { create(:user, :author) }
    before { sign_in author }

    it "redirects the index to the dashboard root" do
      get dashboard_comments_path
      expect(response).to redirect_to(dashboard_root_path)
    end
  end

  describe "as a moderator" do
    let(:moderator) { create(:user, :moderator) }
    let(:commenting_user) { create(:user) }
    let(:post_record) { create(:post) }
    let!(:comment) { create(:comment, user: commenting_user, commentable: post_record) }

    before { sign_in moderator }

    it "updates a comment status" do
      patch dashboard_comment_path(comment), params: { comment: { status: "approved" } }
      expect(response).to redirect_to(dashboard_comments_path)
      expect(comment.reload.status).to eq("approved")
    end

    it "discards a comment" do
      delete dashboard_comment_path(comment)
      expect(response).to redirect_to(dashboard_comments_path)
      expect(comment.reload.discarded?).to be true
    end
  end
end
