# frozen_string_literal: true

module Dashboard
  class BasePolicy < ApplicationPolicy
    def dashboard_user?
      user&.author? || user&.moderator? || user&.admin?
    end

    def moderator_or_admin?
      user&.moderator? || user&.admin?
    end

    def author_owns_record?
      return false unless user && record
      owner?
    end

    # The dashboard is intentionally a per-blog workspace: every signed-in
    # author (including moderators and admins) sees ONLY their own content
    # when working under /dashboard. Cross-blog moderation lives in /admin.
    # Scopes here therefore never widen on role.
    class Scope < ApplicationPolicy::Scope
      def resolve_for_author
        relation = scope.respond_to?(:kept) ? scope.kept : scope.all

        if scope.column_names.include?("author_id")
          relation.where(author_id: user.id)
        elsif scope.column_names.include?("user_id")
          relation.where(user_id: user.id)
        else
          relation
        end
      end
    end
  end
end
