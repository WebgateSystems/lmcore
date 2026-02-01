# frozen_string_literal: true

class CreateContentVisibility < ActiveRecord::Migration[8.0]
  def change
    create_table :content_visibilities, id: :uuid do |t|
      # Content (polymorphic)
      t.string :visible_type, null: false
      t.uuid :visible_id, null: false

      # Visibility target (polymorphic - can be UserGroup or specific User)
      t.string :target_type, null: false
      t.uuid :target_id, null: false

      t.string :access_level, default: 'read', null: false # read, comment, hidden

      t.timestamps
    end

    add_index :content_visibilities, %i[visible_type visible_id], name: 'index_visibility_on_visible'
    add_index :content_visibilities, %i[target_type target_id], name: 'index_visibility_on_target'
    add_index :content_visibilities, %i[visible_type visible_id target_type target_id],
              unique: true, name: 'index_visibility_uniqueness'
  end
end
