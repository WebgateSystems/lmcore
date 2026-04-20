# frozen_string_literal: true

require "rails_helper"

# Covers the 404 handling for the public-facing blog. Anything missing —
# unpublished post, deleted video, wrong photo slug, unknown blog username —
# must produce an HTTP 404 with a themed body, NOT bubble up as a 500.
RSpec.describe "Blogs 404 handling", type: :request do
  let(:author) { create(:user, username: "ayder") }

  describe "GET /blogs/:blog_slug/posts/:slug" do
    it "returns 404 (not 500) when the post slug does not exist" do
      get "/blogs/#{author.username}/posts/does-not-exist"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when the post exists but is no longer published" do
      create(:post, author: author, slug: "draft-only", status: "draft")

      get "/blogs/#{author.username}/posts/draft-only"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 when the post has been soft-deleted (discarded)" do
      post = create(:post, :published, author: author, slug: "to-be-discarded")
      post.discard

      get "/blogs/#{author.username}/posts/to-be-discarded"
      expect(response).to have_http_status(:not_found)
    end

    it "marks the response as noindex so crawlers do not retain the gone URL" do
      get "/blogs/#{author.username}/posts/does-not-exist"
      expect(response.headers["X-Robots-Tag"].to_s).to include("noindex")
    end
  end

  describe "GET /blogs/:blog_slug/videos/:slug" do
    it "returns 404 when the video does not exist" do
      get "/blogs/#{author.username}/videos/missing"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /blogs/:blog_slug/photos/:slug" do
    it "returns 404 when the photo does not exist" do
      get "/blogs/#{author.username}/photos/missing"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /blogs/:blog_slug/pages/:slug" do
    it "returns 404 when the page does not exist" do
      get "/blogs/#{author.username}/pages/missing"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /blogs/:blog_slug/categories/:slug" do
    it "returns 404 when the category does not exist" do
      get "/blogs/#{author.username}/categories/missing"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /blogs/:blog_slug/tags/:slug" do
    it "returns 404 when the tag does not exist" do
      get "/blogs/#{author.username}/tags/missing"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /blogs/:wrong_blog_slug" do
    it "returns 404 when the blog owner (username) does not exist" do
      get "/blogs/no-such-user"
      expect(response).to have_http_status(:not_found)
    end
  end
end
