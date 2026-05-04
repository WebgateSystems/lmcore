# frozen_string_literal: true

require "open-uri"
require "tempfile"

module Youtube
  class ThumbnailBackfillService
    attr_reader :scope, :logger, :progress, :stop_requested

    def initialize(scope:, logger: Rails.logger, progress: nil, stop_requested: nil)
      @scope = scope
      @logger = logger
      @progress = progress
      @stop_requested = stop_requested
    end

    # By default returns number of updated records.
    # If return_stats: true, returns a hash with counters.
    def call(return_stats: false)
      total = scope.count
      stats = { total: total, processed: 0, updated: 0, skipped: 0, failed: 0 }
      emit_progress(:start, stats.dup)

      scope.find_each do |video|
        if stop_requested?
          emit_progress(:cancelled, stats: stats.dup, video_id: video.video_external_id)
          break
        end

        begin
          result = ensure_thumbnail_present(video)
          if result
            stats[:updated] += 1
          else
            stats[:skipped] += 1
          end
        rescue StandardError => e
          stats[:failed] += 1
          logger.warn("[YouTube Sync] thumbnail backfill failed video_id=#{video.video_external_id} message=#{e.message}")
          emit_progress(:error, stats: stats.dup, video_id: video.video_external_id, message: e.message)
        ensure
          stats[:processed] += 1
          emit_progress(:progress, stats: stats.dup, video_id: video.video_external_id)
        end
      rescue StandardError => e
        stats[:failed] += 1
        stats[:processed] += 1
        logger.warn("[YouTube Sync] thumbnail backfill failed video_id=#{video.video_external_id} message=#{e.message}")
        emit_progress(:error, stats: stats.dup, video_id: video.video_external_id, message: e.message)
      end

      emit_progress(:finish, stats.dup)
      return stats if return_stats

      stats[:updated]
    end

    private

    def emit_progress(event, payload)
      progress&.call(event, payload)
    rescue StandardError
      nil
    end

    def stop_requested?
      stop_requested.respond_to?(:call) && stop_requested.call
    rescue StandardError
      false
    end

    def ensure_thumbnail_present(video)
      return false if video.thumbnail_file_available?

      thumbnail_candidates_for(video).each do |url|
        next if url.blank?
        next unless assign_thumbnail_from_url(video, url)

        return true
      end

      false
    end

    def assign_thumbnail_from_url(video, url)
      ext = File.extname(URI.parse(url).path.to_s).to_s.downcase
      ext = ".jpg" if ext.blank?

      Tempfile.create([ "yt-thumb-", ext ]) do |tmp|
        URI.open(url, "rb", read_timeout: 8, open_timeout: 5) do |remote_io|
          IO.copy_stream(remote_io, tmp)
        end
        tmp.rewind
        video.thumbnail = tmp
        video.save!
      end
      true
    rescue StandardError
      false
    end

    def thumbnail_candidates_for(video)
      youtube_data = video.video_data.is_a?(Hash) ? (video.video_data["youtube"] || {}) : {}
      from_list = Array(youtube_data["thumbnails"]).filter_map { |thumb| thumb.is_a?(Hash) ? thumb["url"] : nil }
      from_primary = [ youtube_data["thumbnail"], *deterministic_youtube_thumbnail_candidates(video), video.external_thumbnail_url ]
      (from_primary + from_list).compact.map(&:to_s).reject(&:blank?).uniq
    end

    def deterministic_youtube_thumbnail_candidates(video)
      return [] unless video.video_provider.to_s == "youtube"

      video_id = video.video_external_id.to_s
      return [] if video_id.blank?

      [
        "https://i.ytimg.com/vi/#{video_id}/maxresdefault.jpg",
        "https://i.ytimg.com/vi/#{video_id}/hqdefault.jpg"
      ]
    end
  end
end
