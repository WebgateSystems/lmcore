# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages, id: :uuid do |t|
      t.references :author, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :published_by, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      t.string :slug, null: false
      t.jsonb :title_i18n, default: {}, null: false
      t.jsonb :content_i18n, default: {}, null: false
      t.jsonb :meta_description_i18n, default: {}

      # Media
      t.string :featured_image
      t.jsonb :featured_image_data, default: {}

      # Page type
      t.string :page_type, default: 'custom', null: false # custom, about, contact, terms, privacy

      # Status
      t.string :status, default: 'draft', null: false

      # Menu
      t.boolean :show_in_menu, default: false, null: false
      t.integer :menu_position, default: 0
      t.jsonb :menu_title_i18n, default: {}

      # Publication
      t.datetime :published_at

      # Soft delete
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :pages, %i[author_id slug], unique: true
    add_index :pages, :page_type
    add_index :pages, :status
    add_index :pages, :show_in_menu
    add_index :pages, :menu_position
    add_index :pages, :discarded_at
  end
end
