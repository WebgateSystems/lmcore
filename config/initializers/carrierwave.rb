# frozen_string_literal: true

CarrierWave.configure do |config|
  config.permissions = 0o644
  config.directory_permissions = 0o755
  config.storage = :file

  # For production, configure cloud storage (e.g., AWS S3)
  # if Rails.env.production?
  #   config.storage = :fog
  #   config.fog_provider = 'fog/aws'
  #   config.fog_credentials = {
  #     provider: 'AWS',
  #     aws_access_key_id: Settings.aws.access_key_id,
  #     aws_secret_access_key: Settings.aws.secret_access_key,
  #     region: Settings.aws.region
  #   }
  #   config.fog_directory = Settings.aws.bucket
  #   config.fog_public = false
  #   config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" }
  # end
end

# Configure MiniMagick
MiniMagick.configure do |config|
  config.timeout = 30
end
