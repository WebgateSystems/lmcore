# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if record.published? && record.visible?
    return true if owner?
    return true if admin?

    record.visible_to?(user)
  end

  def create?
    return false unless user

    user.can_create_post?
  end

  def update?
    owner? || admin?
  end

  def destroy?
    owner? || admin?
  end

  def publish?
    return false unless user

    owner? || admin?
  end

  def archive?
    owner? || admin?
  end

  def feature?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user
        scope.left_joins(:content_visibilities)
             .where(
               "posts.status = ? OR posts.author_id = ? OR " \
               "(content_visibilities.target_type = ? AND content_visibilities.target_id = ?) OR " \
               "content_visibilities.id IS NULL",
               "published", user.id, "User", user.id
             )
             .distinct
      else
        scope.published.visible
      end
    end
  end
end
