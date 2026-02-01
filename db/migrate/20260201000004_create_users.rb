# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      # Devise core
      t.string :email, null: false
      t.string :encrypted_password, null: false

      # Devise recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      # Devise rememberable
      t.datetime :remember_created_at

      # Devise trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      # Devise confirmable
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email

      # Devise lockable
      t.integer :failed_attempts, default: 0, null: false
      t.string :unlock_token
      t.datetime :locked_at

      # Profile
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :display_name
      t.jsonb :bio_i18n, default: {}
      t.string :phone
      t.string :timezone, default: 'UTC'
      t.string :locale, default: 'en'

      # Avatar
      t.string :avatar

      # Status & Role
      t.string :status, default: 'pending', null: false
      t.references :role, type: :uuid, foreign_key: true
      t.references :price_plan, type: :uuid, foreign_key: true

      # Subscription
      t.datetime :subscription_expires_at
      t.integer :posts_this_month, default: 0, null: false
      t.integer :disk_space_used_bytes, default: 0, null: false

      # Vanity domain
      t.string :vanity_domain
      t.boolean :vanity_domain_verified, default: false

      # Settings
      t.jsonb :settings, default: {}
      t.jsonb :notification_preferences, default: {}

      # Soft delete
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true, where: 'username IS NOT NULL'
    add_index :users, :phone, unique: true, where: 'phone IS NOT NULL'
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
    add_index :users, :status
    add_index :users, :vanity_domain, unique: true, where: 'vanity_domain IS NOT NULL'
    add_index :users, :discarded_at
  end
end
