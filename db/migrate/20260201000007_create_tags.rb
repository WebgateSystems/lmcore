# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :taggings_count, default: 0, null: false

      t.timestamps
    end

    add_index :tags, :slug, unique: true
    add_index :tags, :name
    add_index :tags, :taggings_count
  end
end
