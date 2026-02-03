# frozen_string_literal: true

class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Storage configuration
  storage :file

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded
  def default_url(*_args)
    "/images/fallback/#{model.class.to_s.underscore}_#{mounted_as}.png"
  end

  # Process files as they are uploaded
  def filename
    "#{secure_token}.#{file.extension}" if file
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.uuid)
  end
end
