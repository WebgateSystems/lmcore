# frozen_string_literal: true

class AvatarUploader < BaseUploader
  # Process files as they are uploaded
  process resize_to_limit: [ 500, 500 ]

  # Create different versions of your uploaded files
  version :thumb do
    process resize_to_fill: [ 100, 100 ]
  end

  version :medium do
    process resize_to_fill: [ 200, 200 ]
  end

  # Add an allowlist of extensions which are allowed to be uploaded
  def extension_allowlist
    %w[jpg jpeg gif png webp]
  end

  # Override the directory where uploaded files will be stored
  def store_dir
    "uploads/avatars/#{model.id}"
  end

  # Limit file size
  def size_range
    1..5.megabytes
  end

  def content_type_allowlist
    %r{image/}
  end
end
