# frozen_string_literal: true

module Dashboard
  class PartnerPolicy < BasePolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.where(user: user)
      end
    end

    def index?
      dashboard_user?
    end

    def create?
      dashboard_user?
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
      dashboard_user?
    end

    # Authors manage their own partner list. Cross-blog management lives
    # in /admin if it's ever needed.
    def destroy?
      author_owns_record?
    end
  end
end
