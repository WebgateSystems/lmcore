# frozen_string_literal: true

module Dashboard
  class TagPolicy < BasePolicy
    # Tags themselves are a global vocabulary (shared across the platform),
    # but on the per-blog /dashboard view we only surface tags that the
    # author has actually used on their own posts/videos/photos.
    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        taggable_subqueries = [
          Tagging.where(taggable_type: "Post",  taggable_id: Post.where(author_id: user.id).select(:id)),
          Tagging.where(taggable_type: "Video", taggable_id: Video.where(author_id: user.id).select(:id)),
          Tagging.where(taggable_type: "Album", taggable_id: Album.where(author_id: user.id).select(:id))
        ]
        tag_ids = taggable_subqueries.map { |rel| rel.select(:tag_id) }
        scope.where(id: tag_ids.first).or(scope.where(id: tag_ids.second)).or(scope.where(id: tag_ids.third))
      end
    end

    def index?
      dashboard_user?
    end

    def show?
      dashboard_user?
    end

    def create?
      dashboard_user?
    end

    def new?
      create?
    end

    # Tags are a global vocabulary -- editing/deleting them affects every
    # blog on the platform, so it stays a /admin-only privilege. Authors
    # manage their tag *associations* via the post/video/photo edit forms.
    def update?
      false
    end

    def edit?
      update?
    end

    def destroy?
      false
    end
  end
end
