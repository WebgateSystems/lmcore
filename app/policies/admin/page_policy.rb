# frozen_string_literal: true

module Admin
  class PagePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        else
          scope.none
        end
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
      user.admin?
    end

    def publish?
      user.admin?
    end

    def unpublish?
      user.admin?
    end
  end
end
