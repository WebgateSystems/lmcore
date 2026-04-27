# frozen_string_literal: true

class CreateContactMessagesAndNewsletterSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_messages, id: :uuid do |t|
      t.references :blog_owner, null: false, type: :uuid, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :email, null: false
      t.text :message, null: false
      t.string :status, null: false, default: "new"

      t.timestamps
    end

    add_index :contact_messages, :created_at
    add_index :contact_messages, :status

    create_table :newsletter_subscriptions, id: :uuid do |t|
      t.references :blog_owner, null: false, type: :uuid, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :email, null: false
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :newsletter_subscriptions, %i[blog_owner_id email], unique: true
    add_index :newsletter_subscriptions, :status
  end
end
