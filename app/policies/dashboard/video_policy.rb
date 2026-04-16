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
      author_owns_record?
    end

    def create?
      dashboard_user?
    end

    def new?
      create?
    end

    def update?
      author_owns_record?
    end

    def edit?
      update?
    end

    def destroy?
      author_owns_record?
    end

    def sync_youtube?
      dashboard_user?
    end

    def create_post_from_video?
      author_owns_record?
    end
  end
end
