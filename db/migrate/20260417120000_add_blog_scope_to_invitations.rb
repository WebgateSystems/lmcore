# frozen_string_literal: true

class AddBlogScopeToInvitations < ActiveRecord::Migration[8.0]
  def change
    add_column :invitations, :blog_owner_id, :uuid
    add_column :invitations, :blog_role_slug, :string
    add_index :invitations, :blog_owner_id
    add_index :invitations, %i[blog_owner_id status]
  end
end
