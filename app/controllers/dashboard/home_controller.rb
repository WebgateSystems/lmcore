# frozen_string_literal: true

module Dashboard
  class HomeController < BaseController
    def index
      skip_authorization
      skip_policy_scope

      @posts_count = scoped_posts.count
      @videos_count = scoped_videos.count
      @photos_count = scoped_albums.count
      @pages_count = scoped_pages.count
      @comments_count = scoped_comments.count

      @recent_posts = scoped_posts.order(created_at: :desc).limit(5)
      @draft_posts = scoped_posts.where(status: :draft).order(updated_at: :desc).limit(5)
    end
  end
end
