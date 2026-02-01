# frozen_string_literal: true

class CreateApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.string :name, null: false
      t.string :key_digest, null: false
      t.string :prefix, null: false # First 8 chars for identification

      t.jsonb :scopes, default: []
      t.datetime :last_used_at
      t.datetime :expires_at
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :api_keys, :key_digest, unique: true
    add_index :api_keys, :prefix
    add_index :api_keys, :active
  end
end
