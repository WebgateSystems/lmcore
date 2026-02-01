# frozen_string_literal: true

class CreateThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :author
      t.string :version, default: '1.0.0'
      t.string :path

      # Configuration
      t.jsonb :config, default: {}
      t.jsonb :color_scheme, default: {}
      t.jsonb :typography, default: {}

      # Preview
      t.string :preview_image
      t.jsonb :preview_image_data, default: {}
      t.jsonb :screenshots, default: []

      # Status
      t.string :status, default: 'inactive', null: false # inactive, active, default
      t.boolean :is_system, default: false, null: false
      t.boolean :is_premium, default: false, null: false

      # Pricing (for premium themes)
      t.integer :price_cents, default: 0
      t.string :currency, default: 'EUR'

      t.timestamps
    end

    add_index :themes, :slug, unique: true
    add_index :themes, :status
    add_index :themes, :is_system
    add_index :themes, :is_premium
  end
end
