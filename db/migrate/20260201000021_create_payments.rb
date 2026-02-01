# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :subscription, type: :uuid, foreign_key: { on_delete: :nullify }

      t.string :payment_provider, null: false # stripe, paypal
      t.string :external_payment_id
      t.string :payment_type, null: false # subscription, donation, theme_purchase

      t.integer :amount_cents, null: false
      t.string :currency, default: 'EUR', null: false
      t.integer :fee_cents, default: 0
      t.integer :net_amount_cents, default: 0

      t.string :status, default: 'pending', null: false # pending, completed, failed, refunded
      t.text :failure_reason
      t.datetime :paid_at
      t.datetime :refunded_at

      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :payments, :external_payment_id
    add_index :payments, :payment_type
    add_index :payments, :status
    add_index :payments, :paid_at
  end
end
