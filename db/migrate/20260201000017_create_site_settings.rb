# frozen_string_literal: true

class CreateSiteSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :site_settings, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: { on_delete: :cascade }

      t.string :key, null: false
      t.jsonb :value, default: {}
      t.string :category, default: 'general'
      t.string :value_type, default: 'string' # string, integer, boolean, json, text
      t.text :description

      t.timestamps
    end

    add_index :site_settings, %i[user_id key], unique: true
    add_index :site_settings, :category
  end
end
