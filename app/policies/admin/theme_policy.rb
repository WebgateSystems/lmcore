# frozen_string_literal: true

module Admin
  class ThemePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        user.admin? ? scope.all : scope.none
      end
    end

    def index?
      user.admin?
    end

    def show?
      user.admin?
    end

    def create?
      user.admin?
    end

    def new?
      create?
    end

    def update?
      user.admin?
    end

    def edit?
      update?
    end

    def destroy?
      user.admin? && !record.default?
    end
  end
end
