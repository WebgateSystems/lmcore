# frozen_string_literal: true

module Dashboard
  class SettingsPolicy < BasePolicy
    def show?
      dashboard_user?
    end

    def update?
      dashboard_user?
    end
  end
end
