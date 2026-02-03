# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExtractExifDataWorker, type: :worker do
  let(:author) { create(:user) }

  describe "#perform" do
    it "does nothing when photo not found" do
      expect {
        described_class.new.perform("nonexistent-id")
      }.not_to raise_error
    end

    it "handles photo with image that has no file gracefully" do
      # Create a photo with a valid image first
      photo = create(:photo, author: author)
      # Stub the image file path to return nil
      allow_any_instance_of(ImageUploader).to receive(:file).and_return(nil)

      expect {
        described_class.new.perform(photo.id)
      }.not_to raise_error
    end
  end

  describe "sidekiq options" do
    it "uses low priority queue" do
      expect(described_class.sidekiq_options["queue"]).to eq(:low)
    end
  end

  describe "#extract_exif" do
    let(:worker) { described_class.new }

    it "returns empty hash for non-existent file" do
      result = worker.send(:extract_exif, "/nonexistent/path")
      expect(result).to eq({})
    end
  end
end
