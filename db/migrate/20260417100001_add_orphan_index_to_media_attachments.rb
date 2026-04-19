# frozen_string_literal: true

# NOTE: orphan attachments are media_attachments with attachable_id IS NULL.
# They are uploaded by users while creating a Post that hasn't been saved yet,
# and get attached on Post#create. CleanupOrphanMediaAttachmentsWorker scans this
# index daily and removes orphans older than 24h.
class AddOrphanIndexToMediaAttachments < ActiveRecord::Migration[8.0]
  def change
    add_index :media_attachments, :created_at,
              where: "attachable_id IS NULL",
              name: "idx_media_attachments_orphans"
  end
end
