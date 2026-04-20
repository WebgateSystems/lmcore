# frozen_string_literal: true

require "rails_helper"

# Covers the bits of `Publishable` that aren't already covered by the
# AASM-driven status transitions in the model specs themselves -- chiefly
# `toggle_pinned!`, which powers the dashboard's "Top" pin button and the
# matching `featured: true` slot on the public blog homepage.
RSpec.describe Publishable, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:author) { create(:user) }
  let(:other_author) { create(:user) }

  describe "#toggle_pinned!" do
    it "pins a previously-unpinned record and returns true" do
      record = create(:post, author: author, featured: false)

      expect(record.toggle_pinned!).to be true
      expect(record.reload.featured?).to be true
    end

    it "unpins an already-pinned record and returns false" do
      record = create(:post, author: author, featured: true)

      expect(record.toggle_pinned!).to be false
      expect(record.reload.featured?).to be false
    end

    it "single-selects within an author's own collection (unpins siblings)" do
      old_top = create(:post, author: author, featured: true)
      another = create(:post, author: author, featured: false)

      another.toggle_pinned!

      expect(old_top.reload.featured?).to be false
      expect(another.reload.featured?).to be true
    end

    it "does not touch other authors' pins" do
      mine    = create(:post, author: author, featured: false)
      foreign = create(:post, author: other_author, featured: true)

      mine.toggle_pinned!

      expect(foreign.reload.featured?).to be true
    end

    it "is independent across content types (pinning a video does not unpin a post)" do
      pinned_post  = create(:post,  author: author, featured: true)
      video        = create(:video, author: author, featured: false)

      video.toggle_pinned!

      expect(pinned_post.reload.featured?).to be true
      expect(video.reload.featured?).to be true
    end

    it "skips validations and callbacks (uses update_columns)" do
      record = create(:post, author: author, featured: false)
      # Make the record invalid in memory; toggle_pinned! must still flip
      # the flag because it bypasses the validation chain.
      record.title_i18n = {}
      expect(record).not_to be_valid

      expect { record.toggle_pinned! }.not_to raise_error
      expect(record.reload.featured?).to be true
    end

    it "rolls back the whole flip if the inner update_all blows up" do
      record = create(:post, author: author, featured: false)
      sibling = create(:post, author: author, featured: true)

      allow_any_instance_of(ActiveRecord::Relation)
        .to receive(:update_all).and_raise(ActiveRecord::StatementInvalid)

      expect { record.toggle_pinned! }.to raise_error(ActiveRecord::StatementInvalid)
      expect(record.reload.featured?).to be false
      expect(sibling.reload.featured?).to be true
    end
  end

  describe "scopes" do
    it ".featured returns only records with featured: true" do
      pinned = create(:post, author: author, featured: true)
      create(:post, author: author, featured: false)

      expect(Post.featured).to contain_exactly(pinned)
    end
  end

  describe "#visible?" do
    it "is true for a published post with a published_at in the past" do
      record = create(:post, :published, author: author, published_at: 1.hour.ago)
      expect(record).to be_visible
    end

    it "is false for a draft" do
      record = create(:post, author: author, status: "draft", published_at: 1.hour.ago)
      expect(record).not_to be_visible
    end

    it "is false for a published post scheduled in the future" do
      record = build(:post, :published, author: author, published_at: 1.hour.from_now)
      record.save(validate: false)
      expect(record).not_to be_visible
    end
  end

  describe "#publish_now!" do
    it "transitions to published and sets published_at to now" do
      record = create(:post, author: author, status: "draft")

      freeze_time do
        record.publish_now!
        expect(record.reload).to be_published
        expect(record.published_at).to eq(Time.current)
      end
    end
  end
end
