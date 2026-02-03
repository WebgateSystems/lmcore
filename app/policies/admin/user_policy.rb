# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.super_admin?
          scope.all
        elsif user.admin?
          # Admins can see everyone except super_admins (using role_assignments)
          super_admin_ids = RoleAssignment.joins(:role)
                                          .where(roles: { slug: "super-admin" }, scope_type: nil)
                                          .active
                                          .pluck(:user_id)
          scope.where.not(id: super_admin_ids)
        else
          scope.none
        end
      end
    end

    def index?
      user.admin?
    end

    def show?
      return false unless user.admin?
      return true if user.super_admin?

      # Admins cannot view super_admin profiles
      !record.super_admin?
    end

    def create?
      user.admin?
    end

    def new?
      create?
    end

    def update?
      return false unless user.admin?
      return true if user.super_admin?

      # Admins cannot edit super_admins or their own role
      !record.super_admin? && record != user
    end

    def edit?
      update?
    end

    def destroy?
      return false unless user.super_admin?

      # Cannot delete yourself
      record != user
    end

    def suspend?
      return false unless user.admin?
      return true if user.super_admin?

      # Admins cannot suspend other admins or super_admins
      !record.admin?
    end

    def activate?
      return false unless user.admin?
      return true if user.super_admin?

      # Admins can activate non-admin users
      !record.admin?
    end

    def change_role?
      # Admins can assign roles, super_admin for super-admin role
      user.admin?
    end

    def add_role?
      # Admins can assign roles
      user.admin?
    end

    def remove_role?
      # Admins can remove roles
      # But cannot remove their own super-admin role
      user.admin?
    end

    def impersonate?
      return false unless user.super_admin?

      # Cannot impersonate yourself or other super_admins
      record != user && !record.super_admin?
    end
  end
end
