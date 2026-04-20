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

  describe "#increment_views!" do
    it "bumps the views_count counter" do
      expect { photo.increment_views! }.to change { photo.reload.views_count }.by(1)
    end
  end

  describe "image dimensions / orientation helpers" do
    it "returns nil dimensions when image_data is missing" do
      photo.update_column(:image_data, nil)
      expect(photo.dimensions).to be_nil
      expect(photo.aspect_ratio).to be_nil
      expect(photo.landscape?).to be_falsey
      expect(photo.portrait?).to be_falsey
      expect(photo.square?).to be_falsey
    end

    it "computes dimensions and aspect_ratio from image_data" do
      photo.update_column(:image_data, { "width" => 1600, "height" => 900 })
      expect(photo.dimensions).to eq(width: 1600, height: 900)
      expect(photo.aspect_ratio).to be_within(0.001).of(1600.0 / 900.0)
    end

    it "is landscape when ratio > 1" do
      photo.update_column(:image_data, { "width" => 1600, "height" => 900 })
      expect(photo).to be_landscape
      expect(photo).not_to be_portrait
    end

    it "is portrait when ratio < 1" do
      photo.update_column(:image_data, { "width" => 600, "height" => 800 })
      expect(photo).to be_portrait
      expect(photo).not_to be_landscape
    end

    it "is square when ratio is within 0.1 of 1.0" do
      photo.update_column(:image_data, { "width" => 800, "height" => 800 })
      expect(photo).to be_square
    end

    it "tolerates zero/missing dimensions in the JSON blob" do
      photo.update_column(:image_data, { "width" => 0, "height" => nil })
      expect(photo.aspect_ratio).to be_nil
    end
  end

  describe "EXIF helpers" do
    it "camera_info returns nil with no EXIF data" do
      expect(photo.camera_info).to be_nil
    end

    it "camera_info returns a compacted hash with the populated fields" do
      photo.update_column(:exif_data, {
        "make" => "Fujifilm", "model" => "X-T4",
        "focal_length" => "23mm", "aperture" => "f/1.4",
        "shutter_speed" => "1/250", "iso" => 200,
        "lens" => nil, "date_time_original" => nil
      })
      info = photo.camera_info
      expect(info[:make]).to eq("Fujifilm")
      expect(info[:model]).to eq("X-T4")
      expect(info).not_to have_key(:lens) # nil values compacted out
    end

    it "location_info returns nil when EXIF has no GPS data" do
      photo.update_column(:exif_data, { "make" => "Canon" })
      expect(photo.location_info).to be_nil
    end

    it "location_info returns the populated GPS subset" do
      photo.update_column(:exif_data, {
        "gps_latitude" => 50.06, "gps_longitude" => 19.94, "gps_altitude" => 219
      })
      expect(photo.location_info).to eq(latitude: 50.06, longitude: 19.94, altitude: 219)
    end
  end

  describe "default-title autogeneration" do
    it "fills the title from the uploaded filename when none provided" do
      author = create(:user)
      raw = build(:photo, author: author, title_i18n: {}).tap(&:save!)
      expect(raw.title.to_s).not_to be_blank
    end
  end
end
