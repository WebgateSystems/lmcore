# frozen_string_literal: true

class SyncYoutubeChannelVideosWorker < ApplicationWorker
  sidekiq_options queue: :low

  def perform(user_id, channel_url, locale = nil, category_slug = nil, job_run_id = nil)
    user = User.find_by(id: user_id)
    return unless user

    job_run = DashboardJobRun.find_by(id: job_run_id, user:) if job_run_id.present?
    job_run&.mark_running!(stage: "starting")

    result = nil
    user.with_youtube_cookies_file do |cookies_path|
      result = Youtube::ChannelVideosSyncService.new(
        user: user,
        channel_url: channel_url,
        locale: locale,
        category_slug: category_slug,
        progress_every: 50,
        download_thumbnails: true,
        playlist_items: nil,
        cookies_path: cookies_path,
        progress: lambda do |event, payload|
          case event
          when :start
            Rails.logger.info("[YouTube Sync] start user=#{payload[:user_id]} channel=#{payload[:channel_url]} thumbs=#{payload[:download_thumbnails]} sleep_requests=#{payload[:sleep_requests]} retries=#{payload[:retry_limit]}")
            job_run&.update!(stage: "start", status: "running", started_at: job_run.started_at || Time.current)
          when :phase
            Rails.logger.info("[YouTube Sync] phase=#{payload[:name]}")
            job_run&.update!(stage: payload[:name].to_s, status: "running")
          when :phase_heartbeat
            Rails.logger.info("[YouTube Sync] ...phase=#{payload[:phase]} elapsed=#{payload[:elapsed_s]}s")
          when :discovered
            Rails.logger.info("[YouTube Sync] discovered total=#{payload[:total]}")
            job_run&.update!(progress_total: payload[:total].to_i)
          when :progress
            Rails.logger.info("[YouTube Sync] progress #{payload[:index]}/#{payload[:total]} (#{payload[:percent]}%) result=#{payload[:result]} stats=#{payload[:stats]}")
            if job_run
              stats = payload[:stats] || {}
              job_run.update!(
                progress_current: payload[:index].to_i,
                progress_total: payload[:total].to_i.nonzero? || job_run.progress_total,
                created_count: stats[:created].to_i,
                updated_count: stats[:updated].to_i,
                skipped_count: stats[:skipped].to_i,
                error_count: stats[:errors].to_i,
                last_video_id: payload[:video_id].to_s,
                stage: "importing",
                status: "running"
              )
            end
          when :error
            Rails.logger.error("[YouTube Sync] error video_id=#{payload[:video_id]} message=#{payload[:message]}")
            if job_run
              stats = payload[:stats] || {}
              job_run.update!(
                error_count: stats[:errors].to_i,
                last_video_id: payload[:video_id].to_s,
                error_message: payload[:message].to_s,
                stage: payload[:stage].presence || "error",
                status: "running"
              )
            end
          when :skip
            Rails.logger.warn("[YouTube Sync] skipped video_id=#{payload[:video_id]} reason=#{payload[:reason]} message=#{payload[:message]}")
            if job_run
              stats = payload[:stats] || {}
              job_run.update!(
                skipped_count: stats[:skipped].to_i,
                error_count: stats[:errors].to_i,
                last_video_id: payload[:video_id].to_s,
                stage: payload[:stage].presence || "metadata_fetch",
                status: "running"
              )
            end
          when :rate_limited
            Rails.logger.warn("[YouTube Sync] rate_limited video_id=#{payload[:video_id]} attempt=#{payload[:attempt]} sleep=#{payload[:sleep_seconds]}s")
            job_run&.update!(stage: "rate_limited", status: "running", last_video_id: payload[:video_id].to_s)
          when :finish
            Rails.logger.info("[YouTube Sync] finish stats=#{payload[:stats]}")
            job_run&.mark_completed!(stage: "finished", stats: payload[:stats], payload: payload[:stats] || {})
          end
        end
      ).call
    end

    Rails.logger.info("[YouTube Sync] user=#{user.id} stats=#{result}")
  rescue StandardError => e
    job_run&.mark_failed!(error_message: e.message, stage: "failed")
    raise
  end
end
