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
      dashboard_user?
    end

    def edit?
      update?
    end

    def reorder?
      dashboard_user?
    end

    def destroy?
      moderator_or_admin?
    end
  end
end
