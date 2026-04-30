# frozen_string_literal: true

module Dashboard
  class BasePolicy < ApplicationPolicy
    attr_reader :dashboard_blog_user

    def initialize(user_context, record)
      @dashboard_blog_user = user_context.respond_to?(:dashboard_blog_user) ? user_context.dashboard_blog_user : user_context
      super(user_context.respond_to?(:user) ? user_context.user : user_context, record)
    end

    def dashboard_user?
      user&.dashboard_user? && can_access_dashboard_workspace?
    end

    def moderator_or_admin?
      own_dashboard_workspace? || user&.can_moderate?(dashboard_blog_user)
    end

    def author_owns_record?
      return false unless user && record

      record_in_dashboard_workspace? && can_edit_dashboard_workspace?
    end

    def can_manage_dashboard_content?
      record_in_dashboard_workspace? && can_author_dashboard_workspace?
    end

    def can_author_dashboard_workspace?
      user&.dashboard_user? && (own_dashboard_workspace? || user&.can_author?(dashboard_blog_user))
    end

    def can_edit_dashboard_workspace?
      user&.dashboard_user? && (own_dashboard_workspace? || user&.can_edit?(dashboard_blog_user))
    end

    def can_moderate_dashboard_workspace?
      user&.dashboard_user? && (own_dashboard_workspace? || user&.can_moderate?(dashboard_blog_user))
    end

    private

    def own_dashboard_workspace?
      user&.dashboard_user? && dashboard_blog_user && user.id == dashboard_blog_user.id
    end

    def can_access_dashboard_workspace?
      return false unless user && dashboard_blog_user
      return true if own_dashboard_workspace?

      RoleAssignment.active.for_blog(dashboard_blog_user).where(user: user).exists?
    end

    def record_in_dashboard_workspace?
      return false unless dashboard_blog_user && record

      if record.respond_to?(:author_id)
        record.author_id == dashboard_blog_user.id
      elsif record.respond_to?(:user_id)
        record.user_id == dashboard_blog_user.id
      elsif record.respond_to?(:owner_id)
        record.owner_id == dashboard_blog_user.id
      else
        record == dashboard_blog_user
      end
    end

    class Scope < ApplicationPolicy::Scope
      attr_reader :dashboard_blog_user

      def initialize(user_context, scope)
        @dashboard_blog_user = user_context.respond_to?(:dashboard_blog_user) ? user_context.dashboard_blog_user : user_context
        super(user_context.respond_to?(:user) ? user_context.user : user_context, scope)
      end

      def resolve_for_author
        relation = scope.respond_to?(:kept) ? scope.kept : scope.all

        if scope.column_names.include?("author_id")
          relation.where(author_id: dashboard_blog_user.id)
        elsif scope.column_names.include?("user_id")
          relation.where(user_id: dashboard_blog_user.id)
        else
          relation
        end
      end
    end
  end
end
