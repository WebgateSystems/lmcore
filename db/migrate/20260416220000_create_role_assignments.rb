# frozen_string_literal: true

class CreateRoleAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :role_assignments, id: :uuid, if_not_exists: true do |t|
      t.references :user, type: :uuid, null: false,
                          foreign_key: { on_delete: :cascade }, index: true
      t.references :role, type: :uuid, null: false,
                          foreign_key: { on_delete: :cascade }, index: true
      t.references :granted_by, type: :uuid, null: true,
                                foreign_key: { to_table: :users, on_delete: :nullify }, index: true

      t.string   :scope_type
      t.uuid     :scope_id
      t.datetime :expires_at

      t.timestamps
    end

    add_index :role_assignments, :expires_at,
              name: "index_role_assignments_on_expires_at",
              if_not_exists: true
    add_index :role_assignments, %i[scope_type scope_id],
              name: "idx_role_assignments_scope",
              if_not_exists: true
    add_index :role_assignments, %i[user_id role_id scope_type scope_id],
              unique: true,
              name: "idx_role_assignments_unique",
              if_not_exists: true
  end
end
