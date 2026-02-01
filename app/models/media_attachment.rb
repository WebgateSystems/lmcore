# frozen_string_literal: true

class MediaAttachment < ApplicationRecord
  include Translatable

  # Translations
  translates :title, :alt_text, :caption

  # Associations
  belongs_to :user
  belongs_to :attachable, polymorphic: true, optional: true

  # CarrierWave
  mount_uploader :file, MediaUploader

  # Validations
  validates :attachment_type, presence: true, inclusion: { in: %w[image video document audio] }
  validates :file, presence: true

  # Scopes
  scope :images, -> { where(attachment_type: "image") }
  scope :videos, -> { where(attachment_type: "video") }
  scope :documents, -> { where(attachment_type: "document") }
  scope :audio, -> { where(attachment_type: "audio") }
  scope :unattached, -> { where(attachable_id: nil) }
  scope :ordered, -> { order(position: :asc) }

  # Callbacks
  before_save :set_file_metadata
  after_save :update_user_disk_space

  # Instance methods
  def image?
    attachment_type == "image"
  end

  def video?
    attachment_type == "video"
  end

  def document?
    attachment_type == "document"
  end

  def audio?
    attachment_type == "audio"
  end

  def file_name
    file&.file&.filename
  end

  def file_extension
    File.extname(file_name.to_s).delete(".").downcase
  end

  def human_file_size
    size = file_size_bytes
    return "0 B" if size.zero?

    units = %w[B KB MB GB TB]
    exp = (Math.log(size) / Math.log(1024)).to_i
    exp = units.length - 1 if exp > units.length - 1
    format("%.2f %s", size.to_f / (1024**exp), units[exp])
  end

  private

  def set_file_metadata
    return unless file.present? && file.file.present?

    self.content_type = file.file.content_type
    self.file_size_bytes = file.file.size

    if image?
      image = MiniMagick::Image.open(file.path)
      self.file_data = file_data.merge(
        "width" => image.width,
        "height" => image.height
      )
    end
  rescue StandardError => e
    Rails.logger.error("Failed to extract file metadata: #{e.message}")
  end

  def update_user_disk_space
    return unless saved_change_to_file_size_bytes?

    old_size = saved_change_to_file_size_bytes[0] || 0
    new_size = file_size_bytes || 0
    diff = new_size - old_size

    user.increment!(:disk_space_used_bytes, diff)
  end
end
