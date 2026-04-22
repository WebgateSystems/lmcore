# frozen_string_literal: true

module UploadedFileHelpers
  module_function

  FIXTURES_DIR = Rails.root.join("spec/fixtures/files")

  def fixture_upload(filename, content_type)
    require "rack/test/uploaded_file"
    Rack::Test::UploadedFile.new(FIXTURES_DIR.join(filename), content_type, original_filename: filename)
  end

  def fixture_image_upload
    fixture_upload("test_image.jpg", "image/jpeg")
  end
end

RSpec.configure do |config|
  config.include UploadedFileHelpers
end

FactoryBot::SyntaxRunner.include(UploadedFileHelpers)
