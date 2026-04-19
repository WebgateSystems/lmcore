# frozen_string_literal: true

class AddContentFormatAndSourceToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :content_format, :string, null: false, default: "html"
    add_column :posts, :content_source_i18n, :jsonb, default: {}, null: false
  end
end
