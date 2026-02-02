# frozen_string_literal: true

class AddIconClassToPartners < ActiveRecord::Migration[8.0]
  def change
    add_column :partners, :icon_class, :string, default: 'fa-brands fa-youtube'
    add_column :partners, :locale, :string, default: nil
    add_index :partners, :locale
  end
end
