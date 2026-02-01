# frozen_string_literal: true

class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows, id: :uuid do |t|
      t.references :follower, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :followed, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }

      t.string :status, default: 'active', null: false # active, muted, blocked
      t.boolean :notify_posts, default: true, null: false
      t.boolean :notify_videos, default: true, null: false

      t.timestamps
    end

    add_index :follows, %i[follower_id followed_id], unique: true
    add_index :follows, :status
  end
end
