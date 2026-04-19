# frozen_string_literal: true

module Dashboard
  class TeamInvitationPolicy < BasePolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.for_blog(user).where(status: %w[pending])
      end
    end

    def create?
      dashboard_user?
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
      record.blog_owner_id == user.id
    end
  end
end
