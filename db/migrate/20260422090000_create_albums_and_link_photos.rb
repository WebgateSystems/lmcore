# frozen_string_literal: true

class CreateAlbumsAndLinkPhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :albums, id: :uuid do |t|
      t.references :author, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :category, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :published_by, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :cover_photo, type: :uuid, foreign_key: { to_table: :photos, on_delete: :nullify }

      t.string :slug, null: false
      t.jsonb :title_i18n, default: {}, null: false
      t.jsonb :description_i18n, default: {}
      t.jsonb :keywords_i18n, default: {}

      t.string :status, default: "draft", null: false
      t.boolean :featured, default: false, null: false
      t.boolean :archived, default: false, null: false
      t.boolean :comments_enabled, default: true, null: false

      t.datetime :published_at
      t.datetime :scheduled_at

      t.integer :views_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false
      t.integer :reactions_count, default: 0, null: false
      t.integer :photos_count, default: 0, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :albums, %i[author_id slug], unique: true
    add_index :albums, :status
    add_index :albums, :featured
    add_index :albums, :published_at
    add_index :albums, :discarded_at

    add_reference :photos, :album, type: :uuid, foreign_key: { on_delete: :cascade }
    add_column :photos, :position, :integer, default: 0, null: false
    add_index :photos, %i[album_id position]
  end
end
