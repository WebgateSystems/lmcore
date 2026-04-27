# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Public comments", type: :request do
  let(:author) { create(:user, :author, username: "amg") }
  let(:post_record) do
    create(:post, author: author,
                  status: "published",
                  comments_enabled: true,
                  slug: "hello",
                  published_at: 1.day.ago)
  end

  let(:base_url) { "/blogs/#{author.username}/posts/#{post_record.slug}/comments" }

  describe "POST /blogs/:slug/posts/:slug/comments" do
    it "redirects unauthenticated users to login (Devise)" do
      expect {
        post base_url, params: { comment: { content: "Hi" } }
      }.not_to change(Comment, :count)

      expect(response).to redirect_to(new_user_session_path)
    end

    context "as a confirmed user" do
      let(:commenter) { create(:user) }
      before { sign_in commenter }

      it "creates an approved comment" do
        SiteSetting.set("comments_premoderation_enabled", false, user: author, value_type: "boolean")

        expect {
          post base_url, params: { comment: { content: "Hello" } }
        }.to change(Comment, :count).by(1)

        comment = Comment.last
        expect(comment.user).to eq(commenter)
        expect(comment.status).to eq("approved")
        expect(comment.approved_at).to be_present
        expect(comment.approved_by).to eq(commenter)
      end

      it "creates a pending comment when premoderation is enabled" do
        SiteSetting.set("comments_premoderation_enabled", true, user: author, value_type: "boolean")

        expect {
          post base_url, params: { comment: { content: "Needs review" } }
        }.to change(Comment, :count).by(1)

        comment = Comment.last
        expect(comment.status).to eq("pending")
        expect(comment.approved_at).to be_nil
      end

      it "auto-approves trusted commenters even when premoderation is enabled" do
        SiteSetting.set("comments_premoderation_enabled", true, user: author, value_type: "boolean")
        create(:blog_trusted_commenter, blog_owner: author, user: commenter, granted_by: author)

        expect {
          post base_url, params: { comment: { content: "Trusted comment" } }
        }.to change(Comment, :count).by(1)

        expect(Comment.last.status).to eq("approved")
      end

      it "supports nested replies" do
        parent = create(:comment, commentable: post_record, user: author, status: "approved")
        post base_url, params: { comment: { content: "Reply" }, parent_id: parent.id }
        expect(Comment.last.parent).to eq(parent)
      end

      it "rejects when comments are disabled" do
        post_record.update!(comments_enabled: false)
        expect {
          post base_url, params: { comment: { content: "Hello" } }
        }.not_to change(Comment, :count)
      end

      it "blocks users permanently banned from the blog" do
        create(:blog_ban, blog_owner: author, user: commenter, banned_by: author, reason: "spam")

        expect {
          post base_url, params: { comment: { content: "Hello" } }
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(blog_post_path(blog_slug: author.username, slug: post_record.slug))
      end
    end

    context "as an unconfirmed user" do
      let(:commenter) { create(:user) }
      before do
        commenter.update_column(:confirmed_at, nil)
        sign_in commenter
      end

      it "does not create a comment and is bounced back to login by Devise's confirmable" do
        expect {
          post base_url, params: { comment: { content: "Hi" } }
        }.not_to change(Comment, :count)

        # Warden's after_set_user(:fetch) callback rejects unconfirmed users
        # before our controller code runs, so they're forced back to login.
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
