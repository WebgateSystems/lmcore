# frozen_string_literal: true

module Dashboard
  class AuditLogPolicy < BasePolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        if user.moderator? || user.admin?
          scope.all
        else
          scope.none
        end
      end
    end

    def index?
      moderator_or_admin?
    end

    def show?
      moderator_or_admin?
    end
  end
end
