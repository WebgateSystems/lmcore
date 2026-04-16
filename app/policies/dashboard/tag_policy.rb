# frozen_string_literal: true

module Dashboard
  class TagPolicy < BasePolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.all
      end
    end

    def index?
      dashboard_user?
    end

    def show?
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

    def destroy?
      moderator_or_admin?
    end
  end
end
