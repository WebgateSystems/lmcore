# frozen_string_literal: true

module Dashboard
  class AudiencePolicy < BasePolicy
    def index?
      dashboard_user?
    end

    def ban?
      dashboard_user?
    end

    def trust?
      dashboard_user?
    end

    def untrust?
      dashboard_user?
    end
  end
end
