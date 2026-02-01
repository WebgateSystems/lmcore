# frozen_string_literal: true

class ImageUploader < BaseUploader
  # Process files as they are uploaded
  process :optimize
  process resize_to_limit: [ 2000, 2000 ]

  # Create different versions of your uploaded files
  version :large do
    process resize_to_limit: [ 1200, 1200 ]
  end

  version :medium do
    process resize_to_limit: [ 800, 800 ]
  end

  version :small do
    process resize_to_limit: [ 400, 400 ]
  end

  version :thumb do
    process resize_to_fill: [ 200, 200 ]
  end

  version :og do
    process resize_to_fill: [ 1200, 630 ]
  end

  # Add an allowlist of extensions which are allowed to be uploaded
  def extension_allowlist
    %w[jpg jpeg gif png webp svg]
  end

  # Limit file size
  def size_range
    1..20.megabytes
  end

  def content_type_allowlist
    %r{image/}
  end

  # Optimize images
  def optimize
    return unless file.content_type.start_with?("image/")
    return if file.content_type.include?("svg")

    manipulate! do |img|
      img.strip
      img.quality "85"
      img
    end
  end
end
