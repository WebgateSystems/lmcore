# frozen_string_literal: true

class MediaUploader < BaseUploader
  include CarrierWave::MiniMagick

  # Process images as they are uploaded
  process :process_image, if: :image?

  # Create versions for images only
  version :thumb, if: :image? do
    process resize_to_fill: [ 200, 200 ]
  end

  version :medium, if: :image? do
    process resize_to_limit: [ 800, 800 ]
  end

  # Add an allowlist of extensions which are allowed to be uploaded
  def extension_allowlist
    %w[jpg jpeg gif png webp svg pdf doc docx xls xlsx ppt pptx txt md mp3 wav ogg mp4 webm mov]
  end

  # Limit file size
  def size_range
    1..100.megabytes
  end

  # Override store directory
  def store_dir
    "uploads/media/#{model.user_id}/#{model.id}"
  end

  protected

  def image?(file)
    file.content_type&.start_with?("image/")
  end

  def process_image
    return unless file.content_type&.start_with?("image/")
    return if file.content_type&.include?("svg")

    manipulate! do |img|
      img.strip
      img.quality "85"
      img
    end

    resize_to_limit(2000, 2000)
  end
end
