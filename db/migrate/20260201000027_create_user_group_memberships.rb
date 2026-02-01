# frozen_string_literal: true

class CreateUserGroupMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :user_group_memberships, id: :uuid do |t|
      t.references :user_group, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.string :role, default: 'member', null: false # member, moderator, admin

      t.timestamps
    end

    add_index :user_group_memberships, %i[user_group_id user_id], unique: true, name: 'index_group_memberships_uniqueness'
    add_index :user_group_memberships, :role
  end
end
