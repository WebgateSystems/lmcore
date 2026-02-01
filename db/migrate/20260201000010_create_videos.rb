# frozen_string_literal: true

class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos, id: :uuid do |t|
      t.references :author, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :category, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :published_by, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      t.string :slug, null: false
      t.jsonb :title_i18n, default: {}, null: false
      t.jsonb :subtitle_i18n, default: {}
      t.jsonb :description_i18n, default: {}
      t.jsonb :keywords_i18n, default: {}
      t.jsonb :meta_description_i18n, default: {}

      # Video source
      t.string :video_provider # youtube, vimeo, self_hosted
      t.string :video_external_id
      t.string :video_url
      t.string :video_file
      t.jsonb :video_data, default: {}
      t.integer :duration_seconds

      # Thumbnails
      t.string :thumbnail
      t.jsonb :thumbnail_data, default: {}
      t.string :og_image
      t.jsonb :og_image_data, default: {}

      # Status
      t.string :status, default: 'draft', null: false
      t.boolean :featured, default: false, null: false
      t.boolean :archived, default: false, null: false
      t.boolean :comments_enabled, default: true, null: false

      # Publication
      t.datetime :published_at
      t.datetime :scheduled_at

      # Counters
      t.integer :views_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false
      t.integer :reactions_count, default: 0, null: false

      # External source
      t.string :external_source
      t.string :external_id
      t.datetime :external_date

      # Soft delete
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :videos, %i[author_id slug], unique: true
    add_index :videos, :status
    add_index :videos, :featured
    add_index :videos, :video_provider
    add_index :videos, :published_at
    add_index :videos, :discarded_at
  end
end
