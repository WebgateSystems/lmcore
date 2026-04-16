# frozen_string_literal: true

class AddDisplayNameI18nToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :display_name_i18n, :jsonb, default: {}, null: false
  end
end
