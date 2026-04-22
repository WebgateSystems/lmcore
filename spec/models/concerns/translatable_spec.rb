# frozen_string_literal: true

require "rails_helper"

RSpec.describe Translatable do
  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Translatable

      attribute :title_i18n, default: {}

      translates :title
    end
  end

  let(:record) { klass.new }

  describe "generated translation helpers" do
    it "reads value for explicit locale, then falls back to default and first value" do
      record.title_i18n = { "en" => "Hello", "pl" => "Czesc" }

      expect(record.title(locale: :pl)).to eq("Czesc")
      expect(record.title(locale: :uk)).to eq("Hello")
    end

    it "writes translations with locale-aware setter" do
      record.send(:title=, "Witaj", locale: :pl)
      record.send(:title=, "Hello", locale: :en)
      expect(record.title_i18n).to include("pl" => "Witaj", "en" => "Hello")
    end

    it "exposes translations hash and explicit locale writer" do
      record.set_title("Privit", locale: :uk)
      expect(record.title_translations).to eq("uk" => "Privit")
    end

    it "reports whether a locale translation is present" do
      record.title_i18n = { "en" => "Hello", "ru" => "" }
      expect(record.title_translated?(locale: :en)).to be(true)
      expect(record.title_translated?(locale: :ru)).to be(false)
      expect(record.title_translated?(locale: :pl)).to be(false)
    end
  end
end
