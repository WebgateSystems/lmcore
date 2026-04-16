# frozen_string_literal: true

class AddUniqueIndexesForExternalVideos < ActiveRecord::Migration[8.1]
  def change
    add_index :videos, %i[author_id video_provider video_external_id],
      unique: true,
      where: "video_provider IS NOT NULL AND video_external_id IS NOT NULL",
      name: "index_videos_on_author_provider_external_id_unique"

    add_index :videos, %i[author_id external_source external_id],
      unique: true,
      where: "external_source IS NOT NULL AND external_id IS NOT NULL",
      name: "index_videos_on_author_external_source_id_unique"
  end
end
