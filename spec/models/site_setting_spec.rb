# frozen_string_literal: true

require "rails_helper"

RSpec.describe SiteSetting, type: :model do
  describe "validations" do
    subject { described_class.new(key: "site_name", value: { "data" => "x" }, value_type: "string") }

    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_presence_of(:value_type) }
    it { is_expected.to validate_inclusion_of(:value_type).in_array(%w[string integer boolean json text]) }
  end

  describe ".set / .get" do
    it "creates a global setting when user is nil" do
      described_class.set("site_name", "Libre")
      expect(described_class.get("site_name")).to eq("Libre")
    end

    it "stores user-scoped settings separately from global ones" do
      user = create(:user)
      described_class.set("site_name", "Global")
      described_class.set("site_name", "User-specific", user: user)

      expect(described_class.get("site_name")).to eq("Global")
      expect(described_class.get("site_name", user: user)).to eq("User-specific")
    end

    it "infers value_type from the value" do
      described_class.set("posts_limit", 42)
      expect(described_class.find_by(key: "posts_limit", user_id: nil).value_type).to eq("integer")

      described_class.set("comments_enabled", true)
      expect(described_class.find_by(key: "comments_enabled", user_id: nil).value_type).to eq("boolean")

      described_class.set("config", { "a" => 1 })
      expect(described_class.find_by(key: "config", user_id: nil).value_type).to eq("json")
    end
  end

  describe "#typed_value" do
    it "returns integers when value_type is integer" do
      setting = described_class.create!(key: "limit", value: { "data" => "7" }, value_type: "integer")
      expect(setting.typed_value).to eq(7)
    end

    it "returns booleans when value_type is boolean" do
      setting = described_class.create!(key: "flag", value: { "data" => "true" }, value_type: "boolean")
      expect(setting.typed_value).to eq(true)
    end
  end

  describe ".blog_available_locale_codes_for" do
    let(:user) { create(:user) }

    it "defaults to [en] when no setting exists" do
      expect(described_class.blog_available_locale_codes_for(user)).to eq(%w[en])
    end

    it "normalizes ua to uk and filters to platform locales" do
      described_class.set("available_locales", [ "pl", "ua", "zz" ], user: user)
      expect(described_class.blog_available_locale_codes_for(user)).to eq(%w[pl uk])
    end

    it "parses comma-separated strings" do
      described_class.set("available_locales", "en, pl, uk", user: user)
      expect(described_class.blog_available_locale_codes_for(user)).to eq(%w[en pl uk])
    end

    it "falls back to [en] when all entries get filtered out" do
      described_class.set("available_locales", "", user: user)
      expect(described_class.blog_available_locale_codes_for(user)).to eq(%w[en])
    end
  end

  describe ".normalize_social_links" do
    it "keeps allowed platforms in submitted order and drops blanks" do
      links = described_class.normalize_social_links([
        { "platform" => "github", "url" => "https://github.com/libremedia" },
        { "platform" => "unknown", "url" => "https://example.com" },
        { "platform" => "linkedin", "url" => "" }
      ])

      expect(links).to eq([
        { "platform" => "github", "label" => "GitHub", "url" => "https://github.com/libremedia" }
      ])
    end
  end

  describe ".social_links_from_settings_hash" do
    it "prefers the dynamic social_links setting" do
      links = described_class.social_links_from_settings_hash(
        "social_links" => [ { "platform" => "linkedin", "url" => "https://linkedin.com/in/author" } ],
        "social_facebook" => "https://facebook.com/legacy"
      )

      expect(links).to eq([
        { "platform" => "linkedin", "label" => "LinkedIn", "url" => "https://linkedin.com/in/author" }
      ])
    end

    it "builds a compatibility list from legacy fixed social settings" do
      links = described_class.social_links_from_settings_hash(
        "social_facebook" => "https://facebook.com/author",
        "youtube_url" => "https://youtube.com/@author"
      )

      expect(links).to eq([
        { "platform" => "facebook", "label" => "Facebook", "url" => "https://facebook.com/author" },
        { "platform" => "youtube", "label" => "YouTube", "url" => "https://youtube.com/@author" }
      ])
    end

    it "does not fall back to legacy links after social_links is explicitly cleared" do
      links = described_class.social_links_from_settings_hash(
        "social_links" => [],
        "social_facebook" => "https://facebook.com/legacy"
      )

      expect(links).to eq([])
    end
  end

  describe "#global? / #user_specific?" do
    it "reports global settings correctly" do
      setting = described_class.create!(key: "x", value: { "data" => "y" }, value_type: "string")
      expect(setting.global?).to be true
      expect(setting.user_specific?).to be false
    end

    it "reports user-specific settings correctly" do
      user = create(:user)
      setting = described_class.create!(key: "x", user: user, value: { "data" => "y" }, value_type: "string")
      expect(setting.user_specific?).to be true
      expect(setting.global?).to be false
    end
  end
end
