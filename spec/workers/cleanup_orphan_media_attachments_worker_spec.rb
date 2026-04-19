# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleanupOrphanMediaAttachmentsWorker, type: :worker do
  let(:author) { create(:user, :author) }
  let(:post_record) { create(:post, author: author) }

  describe "#perform" do
    it "removes orphan attachments older than the threshold" do
      old_orphan   = create(:media_attachment, :orphan, user: author)
      old_orphan.update_column(:created_at, 30.hours.ago)

      fresh_orphan = create(:media_attachment, :orphan, user: author)

      attached     = create(:media_attachment, user: author, attachable: post_record)
      attached.update_column(:created_at, 30.hours.ago)

      expect {
        described_class.new.perform
      }.to change(MediaAttachment, :count).by(-1)

      expect(MediaAttachment.exists?(old_orphan.id)).to be(false)
      expect(MediaAttachment.exists?(fresh_orphan.id)).to be(true)
      expect(MediaAttachment.exists?(attached.id)).to be(true)
    end

    it "respects the custom age_hours argument" do
      orphan = create(:media_attachment, :orphan, user: author)
      orphan.update_column(:created_at, 2.hours.ago)

      expect {
        described_class.new.perform(1)
      }.to change(MediaAttachment, :count).by(-1)
    end

    it "returns the number of removed attachments" do
      orphan = create(:media_attachment, :orphan, user: author)
      orphan.update_column(:created_at, 30.hours.ago)

      expect(described_class.new.perform).to eq(1)
    end

    it "swallows per-record errors and continues" do
      bad  = create(:media_attachment, :orphan, user: author)
      bad.update_column(:created_at, 30.hours.ago)
      good = create(:media_attachment, :orphan, user: author)
      good.update_column(:created_at, 30.hours.ago)

      allow_any_instance_of(MediaAttachment).to receive(:destroy).and_wrap_original do |original, *args|
        raise StandardError, "boom" if original.receiver.id == bad.id

        original.call(*args)
      end

      expect { described_class.new.perform }.not_to raise_error
      expect(MediaAttachment.exists?(bad.id)).to be(true)
      expect(MediaAttachment.exists?(good.id)).to be(false)
    end
  end

  describe "sidekiq options" do
    it "uses the low queue" do
      expect(described_class.sidekiq_options["queue"]).to eq(:low)
    end
  end
end
