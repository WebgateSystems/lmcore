# frozen_string_literal: true

module Dashboard
  class CommentPolicy < BasePolicy
    # Scope = comments left under MY content (so I can moderate them).
    # NOT comments I have written elsewhere -- those live on the public blog
    # of whoever owns that thread. The dashboard is per-blog, so authors
    # moderate their own comment threads regardless of platform role.
    class Scope < BasePolicy::Scope
      def resolve
        return scope.none unless user

        post_ids  = Post.where(author_id: user.id).select(:id)
        video_ids = Video.where(author_id: user.id).select(:id)
        photo_ids = Photo.where(author_id: user.id).select(:id)

        scope.where(commentable_type: "Post",  commentable_id: post_ids)
             .or(scope.where(commentable_type: "Video", commentable_id: video_ids))
             .or(scope.where(commentable_type: "Photo", commentable_id: photo_ids))
      end
    end

    def index?
      dashboard_user?
    end

    def show?
      comment_on_my_content?
    end

    def update?
      comment_on_my_content?
    end

    def destroy?
      comment_on_my_content?
    end

    private

    def comment_on_my_content?
      return false unless user && record&.commentable
      owner_id = record.commentable.try(:author_id) || record.commentable.try(:user_id)
      owner_id.present? && owner_id == user.id
    end
  end
end
