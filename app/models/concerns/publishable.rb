# frozen_string_literal: true

module Publishable
  extend ActiveSupport::Concern

  included do
    include AASM

    scope :draft, -> { where(status: "draft") }
    scope :pending, -> { where(status: "pending") }
    scope :published, -> { where(status: "published") }
    scope :archived, -> { where(status: "archived") }
    scope :scheduled, -> { where(status: "scheduled") }
    scope :visible, -> { published.where("published_at <= ?", Time.current) }
    scope :featured, -> { where(featured: true) }

    aasm column: :status, whiny_transitions: false do
      state :draft, initial: true
      state :pending
      state :scheduled
      state :published
      state :archived

      event :submit do
        transitions from: :draft, to: :pending
      end

      event :schedule do
        before do
          self.status = "scheduled"
        end
        transitions from: %i[draft pending], to: :scheduled, guard: :scheduled_at_present?
      end

      event :publish do
        before do
          self.published_at ||= Time.current
          self.published_by ||= Current.user
        end
        transitions from: %i[draft pending scheduled], to: :published
      end

      event :unpublish do
        transitions from: :published, to: :draft
      end

      event :archive do
        before do
          self.archived = true
        end
        transitions from: %i[draft pending published], to: :archived
      end

      event :unarchive do
        before do
          self.archived = false
        end
        transitions from: :archived, to: :draft
      end
    end
  end

  def visible?
    published? && published_at.present? && published_at <= Time.current
  end

  def scheduled_at_present?
    scheduled_at.present? && scheduled_at > Time.current
  end

  def publish_now!
    self.published_at = Time.current
    publish!
  end

  # Toggles the "Top" pin for this record within its author's collection.
  # The "Top" slot on the public homepage is single-select per content type
  # per author: pinning a record automatically unpins every other record of
  # the same class belonging to the same author. Pinning an already-pinned
  # record unpins it, leaving the column without a Top until something else
  # is pinned.
  #
  # We deliberately use `update_columns` / `update_all` so that this single-
  # column flag flip skips validations and unrelated callbacks (e.g. content
  # rerendering on Post) — pinning is a publishing decision, not an edit.
  # Returns the new pinned state (true/false).
  def toggle_pinned!
    new_state = !featured?
    transaction do
      if new_state
        self.class
            .where(author_id: author_id, featured: true)
            .where.not(id: id)
            .update_all(featured: false, updated_at: Time.current)
      end
      update_columns(featured: new_state, updated_at: Time.current)
    end
    new_state
  end
end
