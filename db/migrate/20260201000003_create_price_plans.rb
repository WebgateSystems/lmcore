# frozen_string_literal: true

class CreatePricePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :price_plans, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.jsonb :name_i18n, default: {}
      t.jsonb :description_i18n, default: {}
      t.integer :price_cents, default: 0, null: false
      t.string :currency, default: 'EUR', null: false
      t.string :billing_period, default: 'monthly', null: false # monthly, yearly
      t.integer :posts_limit, default: 30
      t.integer :disk_space_mb, default: 40
      t.jsonb :features, default: {}
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :price_plans, :slug, unique: true
    add_index :price_plans, :active
    add_index :price_plans, :position
  end
end
