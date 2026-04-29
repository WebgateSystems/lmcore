# frozen_string_literal: true

class CreateThemeAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :theme_accesses, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :theme, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :theme_accesses, %i[theme_id user_id], unique: true
  end
end
