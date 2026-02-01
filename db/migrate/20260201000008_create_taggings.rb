# frozen_string_literal: true

class CreateTaggings < ActiveRecord::Migration[8.0]
  def change
    create_table :taggings, id: :uuid do |t|
      t.references :tag, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :taggable_type, null: false
      t.uuid :taggable_id, null: false

      t.timestamps
    end

    add_index :taggings, %i[tag_id taggable_type taggable_id], unique: true, name: 'index_taggings_uniqueness'
    add_index :taggings, %i[taggable_type taggable_id]
  end
end
