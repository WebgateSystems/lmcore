# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: { on_delete: :nullify }

      # What was changed
      t.string :auditable_type, null: false
      t.uuid :auditable_id, null: false

      t.string :action, null: false # create, update, destroy, login, logout, etc.
      t.jsonb :changes_data, default: {}
      t.jsonb :metadata, default: {}

      # Request info
      t.string :ip_address
      t.string :user_agent
      t.string :request_id

      t.datetime :created_at, null: false
    end

    add_index :audit_logs, %i[auditable_type auditable_id]
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
    add_index :audit_logs, :request_id
  end
end
