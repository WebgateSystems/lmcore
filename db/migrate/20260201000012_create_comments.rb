# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: { on_delete: :nullify }
      t.references :parent, type: :uuid, foreign_key: { to_table: :comments, on_delete: :cascade }
      t.references :approved_by, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      # Polymorphic association
      t.string :commentable_type, null: false
      t.uuid :commentable_id, null: false

      # Guest info (when user_id is null)
      t.string :guest_name
      t.string :guest_email

      # Content
      t.text :content, null: false

      # Moderation
      t.string :status, default: 'pending', null: false
      t.datetime :approved_at

      # Metadata
      t.string :ip_address
      t.string :user_agent

      # Counters
      t.integer :replies_count, default: 0, null: false
      t.integer :reactions_count, default: 0, null: false

      # Soft delete
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :comments, %i[commentable_type commentable_id]
    add_index :comments, :status
    add_index :comments, :discarded_at
  end
end
