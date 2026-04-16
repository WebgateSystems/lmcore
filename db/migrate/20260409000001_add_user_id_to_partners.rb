# frozen_string_literal: true

class AddUserIdToPartners < ActiveRecord::Migration[8.0]
  def change
    add_reference :partners, :user, type: :uuid, foreign_key: true, null: true, index: true
  end
end
