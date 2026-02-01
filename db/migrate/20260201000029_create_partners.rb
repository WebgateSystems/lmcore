# frozen_string_literal: true

class CreatePartners < ActiveRecord::Migration[8.0]
  def change
    create_table :partners, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :url
      t.text :logo_svg
      t.string :logo_url
      t.jsonb :description_i18n, default: {}

      t.integer :position, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :partners, :slug, unique: true
    add_index :partners, :active
    add_index :partners, :position
  end
end
