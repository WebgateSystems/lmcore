# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.approved? || owner? || content_owner? || moderator?
  end

  def create?
    return true if user # Logged in users can comment

    # Guest comments allowed if commentable allows them
    record.commentable&.comments_enabled?
  end

  def update?
    owner? && record.pending?
  end

  def destroy?
    owner? || content_owner? || moderator?
  end

  def approve?
    content_owner? || moderator?
  end

  def mark_as_spam?
    content_owner? || moderator?
  end

  def reject?
    content_owner? || moderator?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.moderator?
        scope.all
      elsif user
        scope.where(status: "approved").or(scope.where(user_id: user.id))
      else
        scope.approved
      end
    end
  end

  private

  def content_owner?
    return false unless user && record.commentable

    if record.commentable.respond_to?(:author_id)
      record.commentable.author_id == user.id
    else
      false
    end
  end
end
