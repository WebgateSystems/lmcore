# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tagging, type: :model do
  let(:tag) { create(:tag) }
  let(:post_record) { create(:post) }
  let(:tagging) { create(:tagging, tag: tag, taggable: post_record) }

  describe "associations" do
    it { is_expected.to belong_to(:tag) }
    it { is_expected.to belong_to(:taggable) }
  end

  describe "validations" do
    it "validates uniqueness of tag_id scoped to taggable" do
      tagging
      duplicate = build(:tagging, tag: tag, taggable: post_record)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:tag_id]).to include("has already been taken")
    end
  end

  describe "polymorphic association" do
    it "can tag a post" do
      expect(tagging.taggable).to eq(post_record)
      expect(tagging.taggable_type).to eq("Post")
    end

    it "can tag a video" do
      video = create(:video)
      video_tagging = create(:tagging, tag: tag, taggable: video)

      expect(video_tagging.taggable).to eq(video)
      expect(video_tagging.taggable_type).to eq("Video")
    end

    it "can tag a photo" do
      photo = create(:photo)
      photo_tagging = create(:tagging, tag: tag, taggable: photo)

      expect(photo_tagging.taggable).to eq(photo)
      expect(photo_tagging.taggable_type).to eq("Photo")
    end
  end

  describe "counter cache" do
    it "updates tag taggings_count on create" do
      new_tag = create(:tag)
      expect {
        create(:tagging, tag: new_tag, taggable: post_record)
      }.to change { new_tag.reload.taggings_count }.by(1)
    end

    it "updates tag taggings_count on destroy" do
      tagging
      expect {
        tagging.destroy
      }.to change { tag.reload.taggings_count }.by(-1)
    end
  end
end
