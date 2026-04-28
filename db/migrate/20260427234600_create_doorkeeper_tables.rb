# frozen_string_literal: true

class CreateDoorkeeperTables < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_applications, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, default: "", null: false
      t.boolean :confidential, default: true, null: false
      t.timestamps null: false
    end

    add_index :oauth_applications, :uid, unique: true

    create_table :oauth_access_grants, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :resource_owner, null: false, type: :uuid, polymorphic: true
      t.references :application, null: false, type: :uuid
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, default: "", null: false
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :code_challenge
      t.string :code_challenge_method
      t.string :nonce
    end

    add_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id, on_delete: :cascade
    add_index :oauth_access_grants, :token, unique: true

    create_table :oauth_access_tokens, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :resource_owner, type: :uuid, polymorphic: true
      t.references :application, type: :uuid
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in
      t.string :scopes
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :previous_refresh_token, default: "", null: false
    end

    add_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id, on_delete: :cascade
    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true

    create_table :oauth_openid_requests, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :access_grant, null: false, type: :uuid, foreign_key: { to_table: :oauth_access_grants, on_delete: :cascade }
      t.string :nonce, null: false
      t.string :claims
      t.timestamps null: false
    end
  end
end
