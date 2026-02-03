# frozen_string_literal: true

require "rails_helper"

RSpec.describe Page, type: :model do
  let(:author) { create(:user) }
  let(:page_record) { create(:page, author: author) }

  describe "associations" do
    it { is_expected.to belong_to(:author).class_name("User") }
    it { is_expected.to belong_to(:published_by).class_name("User").optional }
  end

  describe "validations" do
    it "validates uniqueness of slug scoped to author" do
      page_record
      duplicate = build(:page, author: author, slug: page_record.slug)
      expect(duplicate).not_to be_valid
    end

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[draft published]) }
  end

  describe "translations" do
    it "translates title" do
      page_record.update!(title_i18n: { "en" => "English Title", "pl" => "Polish Title" })

      I18n.with_locale(:en) { expect(page_record.title).to eq("English Title") }
      I18n.with_locale(:pl) { expect(page_record.title).to eq("Polish Title") }
    end

    it "translates content" do
      page_record.update!(content_i18n: { "en" => "English Content", "pl" => "Polish Content" })

      I18n.with_locale(:en) { expect(page_record.content).to eq("English Content") }
      I18n.with_locale(:pl) { expect(page_record.content).to eq("Polish Content") }
    end
  end

  describe "#publish!" do
    let(:draft_page) { create(:page, author: author, status: "draft") }

    it "changes status to published" do
      draft_page.publish!
      expect(draft_page.status).to eq("published")
    end

    it "sets published_at" do
      draft_page.publish!
      expect(draft_page.published_at).to be_present
    end
  end

  describe "#unpublish!" do
    let(:published_page) { create(:page, author: author, status: "published") }

    it "changes status to draft" do
      published_page.unpublish!
      expect(published_page.status).to eq("draft")
    end
  end

  describe "#published?" do
    it "returns true when status is published" do
      page_record.update!(status: "published")
      expect(page_record.published?).to be true
    end

    it "returns false when status is draft" do
      page_record.update!(status: "draft")
      expect(page_record.published?).to be false
    end
  end
end
