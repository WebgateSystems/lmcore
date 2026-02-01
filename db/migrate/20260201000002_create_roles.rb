# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.jsonb :name_i18n, default: {}
      t.jsonb :description_i18n, default: {}
      t.jsonb :permissions, default: []
      t.integer :priority, default: 0, null: false
      t.boolean :system_role, default: false, null: false

      t.timestamps
    end

    add_index :roles, :slug, unique: true
    add_index :roles, :name, unique: true
    add_index :roles, :priority
    add_index :roles, :system_role
  end
end
