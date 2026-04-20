# frozen_string_literal: true

require "rails_helper"

# Exercises the cross-locale JSONB title search used both by the
# dashboard (`Post.search_by_title(params[:q])`) and by the public-facing
# blog (`BlogsController#filter_by_i18n_title`). Validates the three things
# we actually rely on:
#   1. matches inside *any* stored locale (so an author can find a post
#      they only entered an English title for, while browsing the PL UI)
#   2. case-insensitive match
#   3. blank query returns the unscoped relation (so callers can chain
#      `.search_by_title(params[:q])` unconditionally)
RSpec.describe TitleSearchable, type: :model do
  let(:author) { create(:user) }

  shared_examples "title searchable" do |factory|
    let!(:english_match) do
      create(factory, author: author, title_i18n: { "en" => "Wonderful Apricots", "pl" => "" })
    end
    let!(:polish_match) do
      create(factory, author: author, title_i18n: { "en" => "", "pl" => "Wspaniałe Apricots Sok" })
    end
    let!(:no_match) do
      create(factory, author: author, title_i18n: { "en" => "Bananas", "pl" => "Banany" })
    end

    it "matches a token stored in the English locale" do
      results = factory.to_s.classify.constantize.search_by_title("apricot")
      expect(results).to include(english_match, polish_match)
      expect(results).not_to include(no_match)
    end

    it "is case-insensitive" do
      klass = factory.to_s.classify.constantize
      expect(klass.search_by_title("APRICOTS")).to include(english_match)
      expect(klass.search_by_title("apricots")).to include(english_match)
    end

    it "returns the full relation when query is blank" do
      klass = factory.to_s.classify.constantize
      expect(klass.search_by_title("")).to include(english_match, polish_match, no_match)
      expect(klass.search_by_title("   ")).to include(english_match, polish_match, no_match)
      expect(klass.search_by_title(nil)).to include(english_match, polish_match, no_match)
    end

    it "escapes LIKE wildcards in the user-supplied query" do
      klass = factory.to_s.classify.constantize
      # `%` would otherwise act as a wildcard and falsely match everything;
      # sanitize_sql_like escapes it so we get a literal-only match (none).
      expect(klass.search_by_title("%")).to be_empty
    end
  end

  describe "Post" do
    include_examples "title searchable", :post
  end

  describe "Video" do
    include_examples "title searchable", :video
  end

  describe "Photo" do
    include_examples "title searchable", :photo
  end
end
