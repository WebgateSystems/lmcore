# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.references :parent, type: :uuid, foreign_key: { to_table: :categories, on_delete: :nullify }
      t.references :user, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :slug, null: false
      t.jsonb :name_i18n, default: {}, null: false
      t.jsonb :description_i18n, default: {}
      t.string :category_type, default: 'general', null: false
      t.string :cover_image
      t.integer :position, default: 0, null: false
      t.integer :posts_count, default: 0, null: false
      t.integer :videos_count, default: 0, null: false
      t.integer :photos_count, default: 0, null: false

      t.timestamps
    end

    add_index :categories, %i[user_id slug], unique: true
    add_index :categories, :category_type
    add_index :categories, :position
  end
end
