# frozen_string_literal: true

class DashboardJobRun < ApplicationRecord
  belongs_to :user
  belongs_to :video, optional: true
  belongs_to :post, optional: true

  validates :job_type, presence: true
  validates :status, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user:) }
  scope :youtube_sync, -> { where(job_type: "youtube_sync") }
  scope :video_to_post, -> { where(job_type: "video_to_post") }
  scope :post_translation, -> { where(job_type: "post_translation") }

  def mark_running!(stage: nil, payload: nil)
    update!(
      status: "running",
      stage: stage || self.stage,
      started_at: started_at || Time.current,
      payload: payload || self.payload
    )
  end

  def mark_failed!(error_message:, stage: nil)
    update!(
      status: "failed",
      stage: stage || self.stage,
      error_message: error_message,
      finished_at: Time.current
    )
  end

  def mark_completed!(stage: nil, payload: nil, stats: nil)
    attrs = {
      status: "completed",
      stage: stage || self.stage,
      finished_at: Time.current
    }
    attrs[:payload] = payload if payload.present?
    if stats.present?
      attrs[:created_count] = stats[:created].to_i
      attrs[:updated_count] = stats[:updated].to_i
      attrs[:skipped_count] = stats[:skipped].to_i
      attrs[:error_count] = stats[:errors].to_i
      attrs[:progress_current] = stats[:processed].to_i
    end
    update!(attrs)
  end
end
