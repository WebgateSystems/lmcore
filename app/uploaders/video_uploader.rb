# frozen_string_literal: true

class VideoUploader < BaseUploader
  # Add an allowlist of extensions which are allowed to be uploaded
  def extension_allowlist
    %w[mp4 webm mov avi mkv]
  end

  # Limit file size
  def size_range
    1..2.gigabytes
  end

  def content_type_allowlist
    %r{video/}
  end

  # Override store directory for videos
  def store_dir
    "uploads/videos/#{model.class.to_s.underscore}/#{model.id}"
  end
end
