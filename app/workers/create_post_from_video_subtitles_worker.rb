# frozen_string_literal: true

class CreatePostFromVideoSubtitlesWorker < ApplicationWorker
  sidekiq_options queue: :low

  def perform(user_id, video_id, job_run_id = nil)
    user = User.find_by(id: user_id)
    video = Video.find_by(id: video_id, author_id: user_id)
    return unless user && video

    job_run = DashboardJobRun.find_by(id: job_run_id, user:)
    job_run&.mark_running!(stage: "starting")

    result = nil
    user.with_youtube_cookies_file do |cookies_path|
      result = Youtube::CreatePostFromVideoSubtitlesService.new(
        user: user,
        video: video,
        cookies_path: cookies_path,
        progress: lambda do |event, payload|
          case event
          when :phase
            job_run&.update!(status: "running", stage: payload[:stage].to_s, started_at: job_run.started_at || Time.current)
          when :finish
            if payload[:result].to_s == "created"
              job_run&.update!(post_id: payload[:post_id], created_count: 1)
            else
              job_run&.update!(skipped_count: 1)
            end
          end
        end
      ).call
    end

    if result[:result] == :created && result[:post].present?
      job_run&.update!(post_id: result[:post].id, created_count: 1)
    elsif result[:result] == :skipped
      job_run&.update!(skipped_count: 1)
    end

    job_run&.mark_completed!(
      stage: "finished",
      payload: {
        result: result[:result].to_s,
        post_id: result[:post]&.id,
        video_id: video.id
      },
      stats: {
        processed: 1,
        created: result[:result] == :created ? 1 : 0,
        updated: 0,
        skipped: result[:result] == :skipped ? 1 : 0,
        errors: 0
      }
    )
  rescue StandardError => e
    job_run&.mark_failed!(error_message: e.message, stage: "failed")
    raise
  end
end
