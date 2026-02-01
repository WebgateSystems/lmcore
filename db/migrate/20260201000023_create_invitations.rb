# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :inviter, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :invitee, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      t.string :email, null: false
      t.string :token, null: false
      t.string :role_type, default: 'user' # user, author, moderator, etc.

      t.string :status, default: 'pending', null: false # pending, accepted, expired, cancelled
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.text :message

      t.timestamps
    end

    add_index :invitations, :email
    add_index :invitations, :token, unique: true
    add_index :invitations, :status
    add_index :invitations, :expires_at
  end
end
