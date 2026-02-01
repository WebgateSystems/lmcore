# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :actor, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      # Polymorphic association for the subject
      t.string :notifiable_type
      t.uuid :notifiable_id

      t.string :notification_type, null: false # new_comment, new_follower, mention, etc.
      t.jsonb :data, default: {}

      t.datetime :read_at
      t.datetime :sent_at
      t.string :delivery_method # email, push, in_app

      t.timestamps
    end

    add_index :notifications, %i[notifiable_type notifiable_id]
    add_index :notifications, :notification_type
    add_index :notifications, :read_at
    add_index :notifications, :created_at
  end
end
