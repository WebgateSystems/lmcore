# frozen_string_literal: true

class ImageUploader < BaseUploader
  # iPhones upload HEIC/HEIF, which browsers can't reliably render.
  # Convert to JPEG up front so that all subsequent processing (resize,
  # versions, optimize) and the stored file are browser-friendly.
  process :convert_heic_to_jpeg
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
  def store_dir
    return youtube_thumbnail_store_dir if youtube_video_thumbnail?

    super
  end

  def extension_allowlist
    %w[jpg jpeg gif png webp heic heif]
  end

  # Limit file size
  def size_range
    1..20.megabytes
  end

  def content_type_allowlist
    [ %r{image/}, "image/heic", "image/heif", "image/heic-sequence", "image/heif-sequence" ]
  end

  # Optimize images
  def optimize
    return unless file.content_type.to_s.start_with?("image/")

    manipulate! do |img|
      img.strip
      img.quality "85"
      img
    end
  end

  # Re-encode HEIC/HEIF to JPEG so it's viewable in every browser.
  # Requires ImageMagick built with libheif (the `heic` delegate).
  #
  # NOTE: in CarrierWave 3 we must call the instance `convert(format)` from
  # `CarrierWave::MiniMagick`, NOT `manipulate!(format: ...)` — `manipulate!`
  # is parameter-less in CW3 and would raise ArgumentError. `convert` runs
  # the conversion AND renames the underlying tempfile/extension, which then
  # propagates through `BaseUploader#filename` (uses `file.extension`).
  def convert_heic_to_jpeg
    return unless heic_or_heif?

    convert("jpg")
  end

  private

  def heic_or_heif?
    ext = File.extname(file.path.to_s).delete(".").downcase
    return true if %w[heic heif].include?(ext)

    file.content_type.to_s.match?(/heic|heif/i)
  end

  def youtube_video_thumbnail?
    model.is_a?(Video) && mounted_as.to_s == "thumbnail" && model.video_provider.to_s == "youtube"
  end

  def youtube_thumbnail_store_dir
    owner = model.author&.username.presence || model.author_id || "unknown"
    file_scope = model.id || "pending"
    "uploads/#{owner}/youtube/thumbnails/#{file_scope}"
  end
end
