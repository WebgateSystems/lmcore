# frozen_string_literal: true

module Dashboard
  class TeamInvitationPolicy < BasePolicy
    class Scope < BasePolicy::Scope
      def resolve
        return scope.none unless user && dashboard_blog_user

        scope.for_blog(dashboard_blog_user).where(status: %w[pending])
      end
    end

    def create?
      own_dashboard_workspace?
    end

    def destroy?
      owns_invitation?
    end

    def resend?
      owns_invitation?
    end

    private

    def owns_invitation?
      return false unless user && record
      own_dashboard_workspace? && record.blog_owner_id == user.id
    end
  end
end
