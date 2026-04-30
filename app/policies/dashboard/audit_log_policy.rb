# frozen_string_literal: true

module Dashboard
  class AuditLogPolicy < BasePolicy
    # Per-blog audit log: only entries that touch the current user's own
    # content, OR entries the user themselves performed. Cross-blog auditing
    # belongs in /admin.
    class Scope < BasePolicy::Scope
      def resolve
        return scope.none unless user && dashboard_blog_user

        post_ids  = Post.where(author_id: dashboard_blog_user.id).select(:id)
        video_ids = Video.where(author_id: dashboard_blog_user.id).select(:id)
        photo_ids = Photo.where(author_id: dashboard_blog_user.id).select(:id)
        page_ids  = Page.where(author_id: dashboard_blog_user.id).select(:id)

        own_content = scope.where(auditable_type: "Post",  auditable_id: post_ids)
                           .or(scope.where(auditable_type: "Video", auditable_id: video_ids))
                           .or(scope.where(auditable_type: "Photo", auditable_id: photo_ids))
                           .or(scope.where(auditable_type: "Page",  auditable_id: page_ids))

        own_content.or(scope.where(user_id: user.id))
      end
    end

    def index?
      can_moderate_dashboard_workspace?
    end

    def show?
      return false unless user && record
      record.user_id == user.id || own_auditable?
    end

    private

    def own_auditable?
      return false unless record.auditable
      owner_id = record.auditable.try(:author_id) || record.auditable.try(:user_id)
      owner_id == dashboard_blog_user.id
    end
  end
end
