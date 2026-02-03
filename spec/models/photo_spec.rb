# frozen_string_literal: true

require "rails_helper"

RSpec.describe Photo, type: :model do
  let(:author) { create(:user) }
  let(:photo) { create(:photo, author: author) }

  describe "associations" do
    it { is_expected.to belong_to(:author).class_name("User") }
    it { is_expected.to belong_to(:category).optional }
    it { is_expected.to belong_to(:published_by).class_name("User").optional }
  end

  describe "validations" do
    it "validates uniqueness of slug scoped to author" do
      photo
      duplicate = build(:photo, author: author, slug: photo.slug)
      expect(duplicate).not_to be_valid
    end

    it { is_expected.to validate_presence_of(:status) }
  end

  describe "translations" do
    it "translates title" do
      photo.update!(title_i18n: { "en" => "Sunset Photo", "pl" => "Zdjęcie Zachodu Słońca" })

      I18n.with_locale(:en) { expect(photo.title).to eq("Sunset Photo") }
      I18n.with_locale(:pl) { expect(photo.title).to eq("Zdjęcie Zachodu Słońca") }
    end

    it "translates description" do
      photo.update!(description_i18n: { "en" => "Beautiful sunset", "pl" => "Piękny zachód słońca" })

      I18n.with_locale(:en) { expect(photo.description).to eq("Beautiful sunset") }
      I18n.with_locale(:pl) { expect(photo.description).to eq("Piękny zachód słońca") }
    end

    it "translates alt_text" do
      photo.update!(alt_text_i18n: { "en" => "Photo of sunset", "pl" => "Zdjęcie zachodu słońca" })

      I18n.with_locale(:en) { expect(photo.alt_text).to eq("Photo of sunset") }
      I18n.with_locale(:pl) { expect(photo.alt_text).to eq("Zdjęcie zachodu słońca") }
    end
  end

  describe "#publish!" do
    let(:draft_photo) { create(:photo, author: author, status: "draft") }

    it "changes status to published" do
      draft_photo.publish!
      expect(draft_photo.status).to eq("published")
    end

    it "sets published_at" do
      draft_photo.publish!
      expect(draft_photo.published_at).to be_present
    end
  end

  describe "#unpublish!" do
    let(:published_photo) { create(:photo, author: author, status: "published") }

    it "changes status to draft" do
      published_photo.unpublish!
      expect(published_photo.status).to eq("draft")
    end
  end
end
