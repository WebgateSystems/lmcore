# frozen_string_literal: true

# Periodically removes MediaAttachment records that were uploaded through the
# rich text editor but never linked to a Post (or any other attachable). The
# threshold is intentionally generous so that a user who left the form open
# overnight will still find their uploads on next save.
#
# Schedule (sidekiq-cron):
#   cleanup_orphan_media_attachments:
#     cron: '15 4 * * *'
#     class: CleanupOrphanMediaAttachmentsWorker
class CleanupOrphanMediaAttachmentsWorker < ApplicationWorker
  sidekiq_options queue: :low

  DEFAULT_AGE_HOURS = 24

  def perform(age_hours = DEFAULT_AGE_HOURS)
    threshold = age_hours.to_i.hours.ago
    scope = MediaAttachment.where(attachable_id: nil)
                           .where("created_at < ?", threshold)

    count = 0
    scope.find_each do |attachment|
      attachment.destroy
      count += 1
    rescue StandardError => e
      Rails.logger.error(
        "[CleanupOrphanMediaAttachmentsWorker] failed for id=#{attachment.id}: #{e.message}"
      )
    end

    Rails.logger.info("[CleanupOrphanMediaAttachmentsWorker] removed #{count} orphan(s) older than #{age_hours}h")
    count
  end
end
