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

  # Global role checks (hierarchical)
  def admin?
    user&.admin?
  end

  def super_admin?
    user&.super_admin?
  end

  # Contextual role checks - checks if user has role on the blog of record's author
  def can_moderate?
    return true if admin?
    return false unless user && record_owner

    user.can_moderate?(record_owner)
  end

  def can_edit?
    return true if admin?
    return false unless user && record_owner

    user.can_edit?(record_owner)
  end

  def can_author?
    return true if admin?
    return false unless user && record_owner

    user.can_author?(record_owner)
  end

  # Get the owner/author of the record (for contextual role checks)
  def record_owner
    return nil unless record

    if record.respond_to?(:author)
      record.author
    elsif record.respond_to?(:user)
      record.user
    elsif record.respond_to?(:owner)
      record.owner
    elsif record.is_a?(User)
      record
    end
  end
end
