# frozen_string_literal: true

class MediaAttachmentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user

      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def show?
    owner_or_admin?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  # Authorization for attaching an existing orphan attachment to a target
  # (e.g. a Post being created). The user must own the orphan AND be allowed
  # to author for the attachable's blog owner.
  def attach?
    owner_or_admin?
  end

  private

  def owner_or_admin?
    return false unless user && record

    record.user_id == user.id || user.admin?
  end
end
