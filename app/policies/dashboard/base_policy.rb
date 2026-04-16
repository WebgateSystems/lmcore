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
      owner? || moderator_or_admin?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve_for_author
        relation = scope.respond_to?(:kept) ? scope.kept : scope.all

        if user.moderator? || user.admin?
          relation
        elsif scope.column_names.include?("author_id")
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
