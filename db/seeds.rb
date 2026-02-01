# frozen_string_literal: true

require 'rack/test'

# Factory class for potential FactoryBot usage in seeds
class Factory
  require 'factory_bot'
  include FactoryBot::Syntax::Methods
end

# Simple logging helper
def log(message) = puts "→ #{message}"

# MIME types for file uploads
MIME = {
  '.png' => 'image/png',
  '.jpg' => 'image/jpeg',
  '.jpeg' => 'image/jpeg',
  '.gif' => 'image/gif',
  '.webp' => 'image/webp',
  '.svg' => 'image/svg+xml',
  '.mp4' => 'video/mp4',
  '.webm' => 'video/webm',
  '.pdf' => 'application/pdf',
  '.srt' => 'text/plain',
  '.vtt' => 'text/vtt'
}.freeze

# Helper for creating uploaded files (CarrierWave compatible)
def uploaded_file(path)
  ext = File.extname(path).downcase
  Rack::Test::UploadedFile.new(path, MIME[ext] || 'application/octet-stream')
end

# Helper for creating temporary files
def tmp_file(ext:, content: 'seed file')
  dir = Rails.root.join('tmp/seeds')
  FileUtils.mkdir_p(dir)
  path = dir.join("#{SecureRandom.hex}.#{ext}")
  File.write(path, content)
  path
end

# Helper for generating placeholder image
def placeholder_image(width: 800, height: 600, text: 'Placeholder')
  dir = Rails.root.join('tmp/seeds')
  FileUtils.mkdir_p(dir)
  path = dir.join("#{SecureRandom.hex}.png")
  # Create minimal valid PNG (1x1 transparent pixel)
  # For real images, you'd use MiniMagick or similar
  png_data = "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1F\x15\xC4\x89\x00\x00\x00\nIDATx\x9Cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xB4\x00\x00\x00\x00IEND\xAEB`\x82"
  File.binwrite(path, png_data)
  path
end

# Load all seed files for the current environment in sorted order
Dir[Rails.root.join('db', 'seeds', Rails.env, '*.rb')].sort.each { |seed| load seed }
