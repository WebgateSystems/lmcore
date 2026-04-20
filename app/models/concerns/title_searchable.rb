# frozen_string_literal: true

# Adds a `search_by_title` scope to models that store translated titles
# in a `title_i18n` JSONB column (Post, Video, Photo, …). The scope matches
# case-insensitively against EVERY locale stored in the JSONB document, so
# an author can find content by typing in any of the languages the title
# was published in — not just the one they're currently viewing the
# dashboard in.
#
# Returns the unscoped relation when the query is blank so callers can
# chain unconditionally:
#
#   Post.where(author: current_user).search_by_title(params[:q]).recent
#
# We deliberately use `LOWER(value) LIKE LOWER(?)` instead of relying on
# Postgres's `ILIKE` because the original value is buried inside
# `jsonb_each_text` and we want the comparison to be obvious to anyone
# reading the SQL. The `EXISTS` subquery short-circuits as soon as one
# locale matches, which keeps it fast even on large JSONB columns.
module TitleSearchable
  extend ActiveSupport::Concern

  included do
    scope :search_by_title, ->(query) {
      next all if query.to_s.strip.blank?

      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)}%"
      where(
        "EXISTS (SELECT 1 FROM jsonb_each_text(#{quoted_table_name}.title_i18n) " \
        "AS title(locale, value) WHERE LOWER(title.value) LIKE LOWER(?))",
        pattern
      )
    }
  end
end
