# frozen_string_literal: true

class CreateUserThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :user_themes, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :theme, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.boolean :active, default: false, null: false
      t.jsonb :customizations, default: {}
      t.datetime :purchased_at

      t.timestamps
    end

    add_index :user_themes, %i[user_id theme_id], unique: true
    add_index :user_themes, %i[user_id active]
  end
end
