# frozen_string_literal: true

require "rails_helper"

RSpec.describe Taggable, type: :model do
  # Use Post as a model that includes Taggable
  let(:author) { create(:user) }
  let(:post_record) { create(:post, author: author) }

  describe "associations" do
    it "has many taggings" do
      expect(post_record).to respond_to(:taggings)
    end

    it "has many tags through taggings" do
      expect(post_record).to respond_to(:tags)
    end
  end

  describe "#tag_list" do
    it "returns comma-separated list of tag names" do
      tag1 = create(:tag, name: "ruby")
      tag2 = create(:tag, name: "rails")
      post_record.tags << [ tag1, tag2 ]

      expect(post_record.tag_list).to include("ruby")
      expect(post_record.tag_list).to include("rails")
    end

    it "returns empty string when no tags" do
      expect(post_record.tag_list).to eq("")
    end
  end

  describe "#tag_list=" do
    it "sets tags from comma-separated string" do
      post_record.tag_list = "ruby, rails, rspec"
      post_record.save!

      expect(post_record.tags.count).to eq(3)
      expect(post_record.tags.map(&:name)).to include("ruby", "rails", "rspec")
    end

    it "sets tags from array" do
      post_record.tag_list = %w[ruby rails]
      post_record.save!

      expect(post_record.tags.count).to eq(2)
    end

    it "creates new tags if they don't exist" do
      expect {
        post_record.tag_list = "newuniquetag"
        post_record.save!
      }.to change(Tag, :count).by(1)
    end

    it "reuses existing tags" do
      existing_tag = create(:tag, name: "existing")

      expect {
        post_record.tag_list = "existing"
        post_record.save!
      }.not_to change(Tag, :count)

      expect(post_record.tags).to include(existing_tag)
    end

    it "handles duplicate tag names" do
      post_record.tag_list = "ruby, ruby, rails"
      post_record.save!

      expect(post_record.tags.count).to eq(2)
    end
  end

  describe "#add_tag" do
    it "adds a tag to the record" do
      post_record.add_tag("newTag")
      expect(post_record.tags.map(&:name)).to include("newtag")
    end

    it "creates the tag if it doesn't exist" do
      expect {
        post_record.add_tag("brandnewtag")
      }.to change(Tag, :count).by(1)
    end

    it "doesn't duplicate existing tags" do
      post_record.add_tag("duplicate")
      post_record.add_tag("duplicate")

      expect(post_record.tags.where(name: "duplicate").count).to eq(1)
    end

    it "returns the tag" do
      tag = post_record.add_tag("returnedtag")
      expect(tag).to be_a(Tag)
      expect(tag.name).to eq("returnedtag")
    end
  end

  describe "#remove_tag" do
    it "removes a tag from the record" do
      tag = create(:tag, name: "to_remove")
      post_record.tags << tag

      post_record.remove_tag("to_remove")
      expect(post_record.tags).not_to include(tag)
    end

    it "doesn't raise error when tag doesn't exist" do
      expect { post_record.remove_tag("nonexistent") }.not_to raise_error
    end
  end

  describe "#has_tag?" do
    it "returns true when record has the tag" do
      tag = create(:tag, name: "present")
      post_record.tags << tag

      expect(post_record.has_tag?("present")).to be true
    end

    it "returns false when record doesn't have the tag" do
      expect(post_record.has_tag?("absent")).to be false
    end
  end
end
