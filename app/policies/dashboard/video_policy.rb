# frozen_string_literal: true

module Dashboard
  class VideoPolicy < BasePolicy
    class Scope < BasePolicy::Scope
      def resolve
        resolve_for_author
      end
    end

    def index?
      dashboard_user?
    end

    def show?
      can_manage_dashboard_content?
    end

    def create?
      can_author_dashboard_workspace?
    end

    def new?
      create?
    end

    def update?
      can_manage_dashboard_content?
    end

    def edit?
      update?
    end

    def destroy?
      can_manage_dashboard_content?
    end

    def sync_youtube?
      can_edit_dashboard_workspace?
    end

    def create_post_from_video?
      can_manage_dashboard_content?
    end

    def pin?
      can_manage_dashboard_content?
    end
  end
end
