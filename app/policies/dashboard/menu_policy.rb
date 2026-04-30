# frozen_string_literal: true

module Dashboard
  class MenuPolicy < BasePolicy
    def show?
      can_edit_dashboard_workspace?
    end

    def update?
      can_edit_dashboard_workspace?
    end
  end
end
