# frozen_string_literal: true

class CreateUserIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :user_identities, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email
      t.jsonb :data, default: {}, null: false
      t.timestamps
    end

    add_index :user_identities, %i[provider uid], unique: true
    add_index :user_identities, %i[user_id provider], unique: true
  end
end
