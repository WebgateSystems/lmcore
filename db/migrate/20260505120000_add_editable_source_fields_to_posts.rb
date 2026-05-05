# frozen_string_literal: true

class AddEditableSourceFieldsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :source_name, :string
    add_column :posts, :source_url, :string
  end
end
