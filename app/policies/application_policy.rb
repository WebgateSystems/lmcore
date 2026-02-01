# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    owner? || admin?
  end

  def edit?
    update?
  end

  def destroy?
    owner? || admin?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  private

  def owner?
    return false unless user && record

    if record.respond_to?(:author_id)
      record.author_id == user.id
    elsif record.respond_to?(:user_id)
      record.user_id == user.id
    elsif record.respond_to?(:owner_id)
      record.owner_id == user.id
    else
      record == user
    end
  end

  def admin?
    user&.admin?
  end

  def super_admin?
    user&.super_admin?
  end

  def moderator?
    user&.moderator?
  end

  def author?
    user&.author?
  end
end
