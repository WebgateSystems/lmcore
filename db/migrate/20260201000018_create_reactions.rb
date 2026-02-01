# frozen_string_literal: true

class CreateReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :reactions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      # Polymorphic association
      t.string :reactable_type, null: false
      t.uuid :reactable_id, null: false

      t.string :reaction_type, null: false # like, love, haha, wow, sad, angry

      t.timestamps
    end

    add_index :reactions, %i[user_id reactable_type reactable_id], unique: true, name: 'index_reactions_uniqueness'
    add_index :reactions, %i[reactable_type reactable_id]
    add_index :reactions, :reaction_type
  end
end
