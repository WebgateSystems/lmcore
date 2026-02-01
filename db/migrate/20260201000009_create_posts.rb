# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts, id: :uuid do |t|
      t.references :author, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :category, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :published_by, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      t.string :slug, null: false
      t.jsonb :title_i18n, default: {}, null: false
      t.jsonb :subtitle_i18n, default: {}
      t.jsonb :lead_i18n, default: {}
      t.jsonb :content_i18n, default: {}, null: false
      t.jsonb :keywords_i18n, default: {}
      t.jsonb :meta_description_i18n, default: {}

      # Media
      t.string :featured_image
      t.jsonb :featured_image_data, default: {}
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

      # External source (for imported content)
      t.string :external_source
      t.string :external_id
      t.datetime :external_date

      # Soft delete
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :posts, %i[author_id slug], unique: true
    add_index :posts, :status
    add_index :posts, :featured
    add_index :posts, :published_at
    add_index :posts, :scheduled_at
    add_index :posts, :discarded_at
    add_index :posts, %i[external_source external_id], unique: true, where: 'external_source IS NOT NULL'
  end
end
