# frozen_string_literal: true

module Admin
  class AuditLogPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.super_admin?
          scope.all
        elsif user.admin?
          # Admins can see all logs except those involving super_admin actions
          scope.where.not(action: %w[impersonate])
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
  end
end
