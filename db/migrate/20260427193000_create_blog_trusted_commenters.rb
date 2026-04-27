# frozen_string_literal: true

class CreateBlogTrustedCommenters < ActiveRecord::Migration[8.0]
  def change
    create_table :blog_trusted_commenters, id: :uuid do |t|
      t.references :blog_owner, null: false, type: :uuid, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :granted_by, null: true, type: :uuid, foreign_key: { to_table: :users, on_delete: :nullify }

      t.timestamps
    end

    add_index :blog_trusted_commenters, %i[blog_owner_id user_id], unique: true, name: "index_blog_trusted_commenters_on_owner_and_user"
  end
end
