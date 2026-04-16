# frozen_string_literal: true

class AddVideoIdToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :video, type: :uuid, foreign_key: { on_delete: :nullify }, index: true
  end
end
