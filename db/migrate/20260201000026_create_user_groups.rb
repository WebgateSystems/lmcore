# frozen_string_literal: true

class CreateUserGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :user_groups, id: :uuid do |t|
      t.references :owner, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }

      t.string :name, null: false
      t.string :slug, null: false
      t.jsonb :description_i18n, default: {}

      t.string :visibility, default: 'private', null: false # private, public
      t.string :cover_image

      t.integer :members_count, default: 0, null: false

      t.timestamps
    end

    add_index :user_groups, %i[owner_id slug], unique: true
    add_index :user_groups, :visibility
  end
end
