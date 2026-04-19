# frozen_string_literal: true

module Dashboard
  # Authorization for the Team management page on /dashboard.
  #
  # Only the blog owner themselves manages their team. Cross-blog team
  # management belongs in /admin (and is not exposed to moderators on the
  # /dashboard side -- that would re-introduce the role bypass we explicitly
  # removed everywhere else under /dashboard).
  class TeamPolicy < BasePolicy
    class Scope < ApplicationPolicy::Scope
      # Returns the RoleAssignments for the current user's own blog scope.
      def resolve
        return scope.none unless user

        scope.for_blog(user).active.includes(:user, :role)
      end
    end

    def index?
      dashboard_user?
    end

    def create?
      dashboard_user?
    end

    def update_role?
      owns_blog_assignment?
    end

    def destroy?
      owns_blog_assignment?
    end

    private

    def owns_blog_assignment?
      return false unless user && record
      record.scope_type == "User" && record.scope_id == user.id
    end
  end
end
