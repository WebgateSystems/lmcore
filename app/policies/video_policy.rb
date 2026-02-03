# frozen_string_literal: true

class VideoPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if record.published? && record.visible?
    return true if owner?
    return true if admin?

    false
  end

  def create?
    return false unless user

    user.has_feature?("external_video") || user.has_feature?("self_hosted_video")
  end

  def update?
    owner? || can_edit?
  end

  def destroy?
    owner? || can_moderate?
  end

  def publish?
    owner? || can_edit?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user
        scope.where(status: "published").or(scope.where(author_id: user.id))
      else
        scope.published.visible
      end
    end
  end
end
