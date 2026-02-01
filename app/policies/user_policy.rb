# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true # Registration is open
  end

  def update?
    owner? || admin?
  end

  def destroy?
    owner? || super_admin?
  end

  def suspend?
    admin? && !record.admin?
  end

  def activate?
    admin?
  end

  def change_role?
    super_admin?
  end

  def change_plan?
    admin? || owner?
  end

  def impersonate?
    super_admin? && !record.super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.active.kept
      end
    end
  end

  private

  def owner?
    user == record
  end
end
