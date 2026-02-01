# frozen_string_literal: true

class CreateDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :donations, id: :uuid do |t|
      t.references :donor, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :recipient, type: :uuid, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :payment, type: :uuid, foreign_key: { on_delete: :nullify }

      # For anonymous donors
      t.string :donor_name
      t.string :donor_email

      t.integer :amount_cents, null: false
      t.string :currency, default: 'EUR', null: false
      t.text :message

      t.string :status, default: 'pending', null: false # pending, completed, failed
      t.boolean :anonymous, default: false, null: false
      t.boolean :recurring, default: false, null: false

      t.timestamps
    end

    add_index :donations, :status
    add_index :donations, :anonymous
    add_index :donations, :recurring
  end
end
