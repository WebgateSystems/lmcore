# frozen_string_literal: true

class AddRelatedVideoUrlToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :related_video_url, :string
  end
end
