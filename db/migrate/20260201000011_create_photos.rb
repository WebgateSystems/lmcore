# frozen_string_literal: true

class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos, id: :uuid do |t|
      t.references :author, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :category, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :published_by, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      t.string :slug, null: false
      t.jsonb :title_i18n, default: {}, null: false
      t.jsonb :description_i18n, default: {}
      t.jsonb :alt_text_i18n, default: {}
      t.jsonb :keywords_i18n, default: {}

      # Photo
      t.string :image, null: false
      t.jsonb :image_data, default: {}
      t.jsonb :exif_data, default: {}

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

      # Soft delete
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :photos, %i[author_id slug], unique: true
    add_index :photos, :status
    add_index :photos, :featured
    add_index :photos, :published_at
    add_index :photos, :discarded_at
  end
end
