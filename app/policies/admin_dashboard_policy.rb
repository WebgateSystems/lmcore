# frozen_string_literal: true

class AdminDashboardPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    index?
  end

  class Scope < Scope
    def resolve
      scope.all if user&.admin?
    end
  end
end
