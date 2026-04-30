# frozen_string_literal: true

module Dashboard
  class PartnerPolicy < BasePolicy
    class Scope < BasePolicy::Scope
      def resolve
        scope.where(user: dashboard_blog_user)
      end
    end

    def index?
      dashboard_user?
    end

    def create?
      can_edit_dashboard_workspace?
    end

    def new?
      create?
    end

    def update?
      author_owns_record?
    end

    def edit?
      update?
    end

    def reorder?
      can_edit_dashboard_workspace?
    end

    # Authors manage their own partner list. Cross-blog management lives
    # in /admin if it's ever needed.
    def destroy?
      author_owns_record?
    end
  end
end
