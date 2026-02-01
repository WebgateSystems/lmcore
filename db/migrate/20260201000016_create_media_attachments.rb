# frozen_string_literal: true

class CreateMediaAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :media_attachments, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      # Polymorphic association
      t.string :attachable_type
      t.uuid :attachable_id

      # File
      t.string :attachment_type, null: false # image, video, document, audio
      t.string :file, null: false
      t.jsonb :file_data, default: {}
      t.string :content_type
      t.integer :file_size_bytes, default: 0

      # Metadata
      t.jsonb :title_i18n, default: {}
      t.jsonb :alt_text_i18n, default: {}
      t.jsonb :caption_i18n, default: {}

      # Ordering
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :media_attachments, %i[attachable_type attachable_id]
    add_index :media_attachments, :attachment_type
    add_index :media_attachments, :position
  end
end
