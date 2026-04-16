# frozen_string_literal: true

class CreateDashboardJobRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :dashboard_job_runs, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :video_id
      t.uuid :post_id
      t.string :job_type, null: false
      t.string :status, null: false, default: "queued"
      t.string :stage
      t.integer :progress_current, null: false, default: 0
      t.integer :progress_total
      t.integer :created_count, null: false, default: 0
      t.integer :updated_count, null: false, default: 0
      t.integer :skipped_count, null: false, default: 0
      t.integer :error_count, null: false, default: 0
      t.string :last_video_id
      t.text :error_message
      t.jsonb :payload, null: false, default: {}
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end

    add_index :dashboard_job_runs, :user_id
    add_index :dashboard_job_runs, :video_id
    add_index :dashboard_job_runs, :post_id
    add_index :dashboard_job_runs, :job_type
    add_index :dashboard_job_runs, :status
    add_index :dashboard_job_runs, %i[user_id job_type created_at], name: "idx_dashboard_job_runs_user_type_created"

    add_foreign_key :dashboard_job_runs, :users, on_delete: :cascade
    add_foreign_key :dashboard_job_runs, :videos, on_delete: :cascade
    add_foreign_key :dashboard_job_runs, :posts, on_delete: :nullify
  end
end
