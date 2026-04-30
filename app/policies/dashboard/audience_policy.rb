# frozen_string_literal: true

module Dashboard
  class AudiencePolicy < BasePolicy
    def index?
      can_moderate_dashboard_workspace?
    end

    def ban?
      can_moderate_dashboard_workspace?
    end

    def trust?
      can_moderate_dashboard_workspace?
    end

    def untrust?
      can_moderate_dashboard_workspace?
    end
  end
end
