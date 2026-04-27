# frozen_string_literal: true

class CreateBlogBans < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_bans, id: :uuid do |t|
      t.references :blog_owner, null: false, type: :uuid, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :banned_by, null: true, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }
      t.text :reason, null: false
      t.boolean :active, null: false, default: true
      t.boolean :permanent, null: false, default: true

      t.timestamps
    end

    add_index :blog_bans, %i[blog_owner_id user_id], unique: true
    add_index :blog_bans, :active
  end
end
