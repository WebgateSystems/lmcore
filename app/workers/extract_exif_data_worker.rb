# frozen_string_literal: true

class ExtractExifDataWorker < ApplicationWorker
  sidekiq_options queue: :low

  def perform(photo_id)
    photo = Photo.find_by(id: photo_id)
    return unless photo&.image&.present?

    exif_data = extract_exif(photo.image.path)
    photo.update_column(:exif_data, exif_data) if exif_data.present?
  rescue StandardError => e
    Rails.logger.error("Failed to extract EXIF data for photo #{photo_id}: #{e.message}")
  end

  private

  def extract_exif(path)
    return {} unless File.exist?(path.to_s)

    image = MiniMagick::Image.open(path)
    exif = image.exif

    {
      "make" => exif["Make"],
      "model" => exif["Model"],
      "lens" => exif["LensModel"],
      "focal_length" => exif["FocalLength"],
      "aperture" => exif["FNumber"],
      "shutter_speed" => exif["ExposureTime"],
      "iso" => exif["ISO"],
      "date_time_original" => exif["DateTimeOriginal"],
      "gps_latitude" => exif["GPSLatitude"],
      "gps_longitude" => exif["GPSLongitude"],
      "gps_altitude" => exif["GPSAltitude"]
    }.compact
  rescue StandardError
    {}
  end
end
