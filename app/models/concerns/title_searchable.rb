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
# We intentionally build a small set of case variants in Ruby and compare
# with plain `LIKE` against each one. This is more robust across databases
# that may run with collations where `LOWER()`/`ILIKE` are effectively
# ASCII-only (which breaks Cyrillic searches such as "шведы" vs "ШВЕДЫ").
# The `EXISTS` subquery still short-circuits as soon as one locale matches.
module TitleSearchable
  extend ActiveSupport::Concern

  included do
    scope :search_by_title, ->(query) {
      next all if query.to_s.strip.blank?

      token = query.to_s.strip
      variants = [
        token,
        token.downcase,
        token.upcase,
        token.capitalize
      ].uniq
      patterns = variants.map { |variant| "%#{ActiveRecord::Base.sanitize_sql_like(variant)}%" }
      # Keep bind arity deterministic and SQL static for scanners/Brakeman.
      patterns << patterns.first while patterns.size < 4
      patterns = patterns.first(4)
      where(
        "EXISTS (SELECT 1 FROM jsonb_each_text(title_i18n) " \
        "AS title(locale, value) WHERE " \
        "title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ? OR title.value LIKE ?)",
        *patterns
      )
    }
  end
end
