# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :price_plan, type: :uuid, null: false, foreign_key: true

      t.string :status, default: 'active', null: false # active, cancelled, expired, past_due
      t.string :payment_provider # stripe, paypal, etc.
      t.string :external_subscription_id

      t.datetime :started_at, null: false
      t.datetime :expires_at
      t.datetime :cancelled_at
      t.datetime :trial_ends_at

      t.boolean :auto_renew, default: true, null: false

      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :subscriptions, :status
    add_index :subscriptions, :external_subscription_id
    add_index :subscriptions, :expires_at
  end
end
