# frozen_string_literal: true

class AddYoutubeCredentialsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :youtube_cookies_ciphertext, :text
    add_column :users, :youtube_cookies_checksum, :string, limit: 64
    add_column :users, :youtube_age_confirmed_at, :datetime
  end
end
