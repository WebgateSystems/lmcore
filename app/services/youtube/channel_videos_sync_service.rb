# frozen_string_literal: true

require "json"
require "open3"
require "time"
require "date"
require "digest"
require "timeout"
require "pathname"
require "fileutils"
require "set"

module Youtube
  class ChannelVideosSyncService
    DEFAULT_LOCALE = "uk"
    DEFAULT_COMMAND_TIMEOUT = 90
    DEFAULT_RETRY_LIMIT = 5
    DEFAULT_RETRY_BASE_DELAY = 45
    DEFAULT_SLEEP_REQUESTS = 1.5

    attr_reader :user, :channel_url, :locale, :category_slug, :logger, :progress, :progress_every, :download_thumbnails, :command_timeout, :playlist_items, :source_json_path, :retry_limit, :retry_base_delay, :sleep_requests, :thumbnail_base_dir, :snapshot_jsonl_path, :cookies_path

    def initialize(user:, channel_url:, locale: nil, category_slug: nil, logger: Rails.logger, progress: nil,
      progress_every: 25, download_thumbnails: false, command_timeout: DEFAULT_COMMAND_TIMEOUT,
      playlist_items: nil, source_json_path: nil, retry_limit: DEFAULT_RETRY_LIMIT,
      retry_base_delay: DEFAULT_RETRY_BASE_DELAY, sleep_requests: DEFAULT_SLEEP_REQUESTS, thumbnail_base_dir: nil,
      snapshot_jsonl_path: nil, cookies_path: nil)
      @user = user
      @channel_url = normalize_channel_url(channel_url)
      @locale = (locale || user.locale || DEFAULT_LOCALE).to_s
      @category_slug = category_slug
      @logger = logger
      @progress = progress
      @progress_every = progress_every.to_i.positive? ? progress_every.to_i : 25
      @download_thumbnails = !!download_thumbnails
      @command_timeout = command_timeout.to_i.positive? ? command_timeout.to_i : DEFAULT_COMMAND_TIMEOUT
      @playlist_items = playlist_items.to_i.positive? ? playlist_items.to_i : nil
      @source_json_path = source_json_path.to_s.strip.presence
      @retry_limit = retry_limit.to_i.positive? ? retry_limit.to_i : DEFAULT_RETRY_LIMIT
      @retry_base_delay = retry_base_delay.to_i.positive? ? retry_base_delay.to_i : DEFAULT_RETRY_BASE_DELAY
      @sleep_requests = sleep_requests.to_f.positive? ? sleep_requests.to_f : DEFAULT_SLEEP_REQUESTS
      @thumbnail_base_dir = thumbnail_base_dir.to_s.strip.presence || Rails.root.join("bin").to_s
      @snapshot_jsonl_path = snapshot_jsonl_path.to_s.strip.presence
      @cookies_path = cookies_path.to_s.strip.presence
    end

    def call
      emit_progress(:start,
        channel_url: channel_url,
        user_id: user.id,
        download_thumbnails: download_thumbnails,
        command_timeout: command_timeout,
        playlist_items: playlist_items,
        source_json_path: source_json_path,
        retry_limit: retry_limit,
        retry_base_delay: retry_base_delay,
        sleep_requests: sleep_requests,
        thumbnail_base_dir: thumbnail_base_dir,
        snapshot_jsonl_path: snapshot_jsonl_path,
        youtube_auth: cookies_path.present?)
      ensure_yt_dlp_available!
      prepare_snapshot_file!

      stats = { processed: 0, created: 0, updated: 0, skipped: 0, errors: 0, format_fallbacks: 0, age_auth_fallbacks: 0, thumbnail_backfilled: 0 }
      if source_json_path.present?
        entries = load_entries_from_file(source_json_path)
        total = entries.size
        emit_progress(:discovered, total: total)
        entries.each_with_index do |entry, index|
          process_entry(entry, index + 1, total, stats)
        end
      else
        total = process_live_entries(stats)
      end

      emit_progress(:finish, stats: stats.dup, total: total)
      stats
    ensure
      close_snapshot_file!
    end

    private

    def ensure_yt_dlp_available!
      _stdout, stderr, status = run_command("yt-dlp", "--version")
      return if status.success?

      raise "yt-dlp is required for YouTube sync (stderr: #{stderr.to_s.strip})"
    end

    def process_live_entries(stats)
      emit_progress(:phase, name: "fetch_video_ids")
      ids = fetch_video_ids
      emit_progress(:phase, name: "fetch_video_ids_done")
      existing_ids = existing_video_ids_for(ids)
      ids_to_fetch = ids.reject { |video_id| existing_ids.include?(video_id) }
      skipped_existing = ids.size - ids_to_fetch.size
      stats[:skipped] += skipped_existing if skipped_existing.positive?
      total = ids_to_fetch.size
      emit_progress(:discovered, total: total)

      if total.zero?
        emit_progress(:phase, name: "no_new_videos")
        return 0
      end

      ids_to_fetch.each_with_index do |video_id, idx|
        emit_progress(:metadata_progress, index: idx + 1, total: total, video_id: video_id)
        fetch_result = fetch_video_metadata_with_retry(video_id, idx + 1, total, stats)
        if fetch_result[:status] == :ok && fetch_result[:entry].present?
          process_entry(fetch_result[:entry], idx + 1, total, stats)
        elsif fetch_result[:status] == :skipped
          stats[:processed] += 1
          stats[:skipped] += 1
          emit_progress(:progress,
            index: idx + 1,
            total: total,
            percent: progress_percent(idx + 1, total),
            video_id: video_id,
            result: :skipped,
            reason: fetch_result[:reason],
            stats: stats.dup)
          emit_progress(:skip,
            video_id: video_id,
            stage: "metadata_fetch",
            reason: fetch_result[:reason],
            message: fetch_result[:message],
            stats: stats.dup)
        else
          stats[:processed] += 1
          stats[:errors] += 1
          emit_progress(:progress,
            index: idx + 1,
            total: total,
            percent: progress_percent(idx + 1, total),
            video_id: video_id,
            result: :error,
            stats: stats.dup)
        end
      end
      backfill_missing_thumbnails(ids, stats)
      total
    end

    def fetch_video_ids
      command = [
        "yt-dlp",
        "--flat-playlist",
        "--dump-single-json",
        "--skip-download",
        "--allow-unplayable-formats",
        "--format", YtDlpDefaults::FORMAT_SELECTOR,
        "--ignore-errors",
        "--no-warnings"
      ]
      command += [ "--playlist-items", playlist_items.to_s ] if playlist_items.present?
      command += yt_dlp_cookie_args
      command << channel_url

      stdout, stderr, status = run_command(*command, phase_name: "fetch_video_ids")
      raise "Failed to fetch video ids: #{stderr.to_s.strip}" unless status.success?

      payload = JSON.parse(stdout)
      Array(payload["entries"]).compact.filter_map { |entry| entry["id"].presence }
    rescue JSON::ParserError => e
      raise "Failed to parse yt-dlp ids JSON: #{e.message}"
    end

    def fetch_video_metadata_with_retry(video_id, index, total, stats)
      attempts = 0
      mode = :default
      begin
        attempts += 1
        tolerant_mode = (mode != :default)
        auth_client_fallback = (mode == :auth_client)
        entry = fetch_video_metadata(video_id, tolerant_mode: tolerant_mode, auth_client_fallback: auth_client_fallback)
        { status: :ok, entry: entry }
      rescue StandardError => e
        if age_restricted_error?(e.message)
          if cookies_path.present? && mode == :default
            stats[:age_auth_fallbacks] += 1
            logger.info("[YouTube Sync] age restricted, retrying metadata with auth client fallback video_id=#{video_id}")
            mode = :auth_client
            retry
          end

          return {
            status: :skipped,
            reason: :age_restricted,
            message: "Skipped video #{video_id}: age-restricted on YouTube (authentication required)"
          }
        end

        if rate_limited_error?(e.message) && attempts <= retry_limit
          sleep_seconds = retry_base_delay * attempts
          emit_progress(:rate_limited, video_id: video_id, attempt: attempts, sleep_seconds: sleep_seconds, message: e.message)
          sleep(sleep_seconds)
          retry
        end

        if format_unavailable_error?(e.message) && mode == :default
          stats[:format_fallbacks] += 1
          logger.info("[YouTube Sync] format unavailable, retrying metadata in tolerant mode video_id=#{video_id}")
          mode = :tolerant
          retry
        end

        emit_progress(:error, video_id: video_id, message: e.message, stage: "metadata_fetch")
        { status: :error, message: e.message }
      end
    end

    def fetch_video_metadata(video_id, tolerant_mode: false, auth_client_fallback: false)
      command = [
        "yt-dlp",
        "--dump-json",
        "--skip-download",
        "--ignore-errors",
        "--no-warnings",
        "--extractor-args", metadata_extractor_args(auth_client_fallback: auth_client_fallback),
        "--sleep-requests", sleep_requests.to_s
      ]
      command << "--ignore-no-formats-error" if tolerant_mode

      stdout, stderr, status = run_command(
        *(command + yt_dlp_cookie_args + [ "https://www.youtube.com/watch?v=#{video_id}" ]),
        phase_name: "fetch_video_metadata"
      )

      raise metadata_fetch_error_message(video_id, stderr) unless status.success?
      JSON.parse(stdout)
    rescue JSON::ParserError => e
      raise "Failed to parse video metadata for #{video_id}: #{e.message}"
    end

    def upsert_video_from_entry(entry)
      normalized = normalize_entry(entry)
      video_id = normalized["id"].to_s
      return :skipped if video_id.blank?

      video = find_existing_video(video_id)
      created = video.new_record?

      title = normalized["title"].to_s.strip
      return :skipped if title.blank?

      description = normalized["description"].to_s
      published_at = parse_published_at(normalized)
      category = find_default_category
      thumbnail_url = best_thumbnail_url(normalized)
      local_thumbnail_path = resolve_local_thumbnail_path(normalized["thumbnail_local_path"])
      should_attach_local_thumbnail = local_thumbnail_path.present? && File.exist?(local_thumbnail_path) && video.thumbnail.blank?

      video.assign_attributes(
        author: user,
        category: category,
        slug: slug_for_video(video, title, video_id),
        video_provider: "youtube",
        video_external_id: video_id,
        video_url: "https://www.youtube.com/watch?v=#{video_id}",
        status: "published",
        published_at: published_at,
        published_by: user,
        duration_seconds: normalized["duration"].presence || video.duration_seconds,
        views_count: normalized["view_count"].presence || video.views_count || 0,
        comments_enabled: true,
        external_source: "youtube",
        external_id: video_id,
        external_date: published_at,
        featured: video.featured || false
      )

      # Keep DB timestamps aligned with actual YouTube publication time.
      if published_at.present? && (created || video.created_at.blank? || video.created_at > published_at)
        video.created_at = published_at
      end

      video.title_i18n = upsert_translated_value(video.title_i18n, title)
      video.description_i18n = upsert_translated_value(video.description_i18n, description) if description.present?

      # Store all user-visible YouTube metadata we can access without auth.
      youtube_payload = {
        "id" => video_id,
        "title" => normalized["title"],
        "description" => normalized["description"],
        "channel" => normalized["channel"],
        "channel_id" => normalized["channel_id"],
        "uploader" => normalized["uploader"],
        "uploader_id" => normalized["uploader_id"],
        "view_count" => normalized["view_count"],
        "like_count" => normalized["like_count"],
        "comment_count" => normalized["comment_count"],
        "duration" => normalized["duration"],
        "duration_string" => normalized["duration_string"],
        "upload_date" => normalized["upload_date"],
        "release_timestamp" => normalized["release_timestamp"],
        "live_status" => normalized["live_status"],
        "availability" => normalized["availability"],
        "webpage_url" => normalized["webpage_url"],
        "thumbnail" => thumbnail_url,
        "thumbnails" => normalized["thumbnails"],
        "channel_url" => normalized["channel_url"],
        "language" => normalized["language"],
        "was_live" => normalized["was_live"],
        "playable_in_embed" => normalized["playable_in_embed"],
        "tags" => normalized["tags"],
        "categories" => normalized["categories"]
      }
      youtube_payload["source_signature"] = Digest::SHA256.hexdigest(JSON.generate(youtube_payload))

      needs_remote_thumbnail = download_thumbnails && video.thumbnail.blank? && thumbnail_url.present?
      if unchanged_video?(video, created: created, youtube_payload: youtube_payload, title: title, description: description, published_at: published_at) && !should_attach_local_thumbnail && !needs_remote_thumbnail
        return :skipped
      end

      video.video_data = {
        "youtube" => {
          **youtube_payload,
          "synced_at" => Time.current.iso8601
        }
      }

      if should_attach_local_thumbnail
        video.thumbnail = File.open(local_thumbnail_path)
      elsif download_thumbnails && thumbnail_url.present?
        video.remote_thumbnail_url = thumbnail_url
      end
      video.save!

      created ? :created : :updated
    end

    def find_existing_video(video_id)
      Video.find_by(author: user, external_source: "youtube", external_id: video_id) ||
        Video.find_by(author: user, video_provider: "youtube", video_external_id: video_id) ||
        Video.new
    end

    def backfill_missing_thumbnails(video_ids, stats)
      return if video_ids.blank?

      emit_progress(:phase, name: "backfill_thumbnails")
      scope = Video.where(author: user, video_provider: "youtube", video_external_id: video_ids)
                   .where(thumbnail: [ nil, "" ])
      updated = Youtube::ThumbnailBackfillService.new(scope: scope, logger: logger).call
      stats[:thumbnail_backfilled] += updated
    end

    def existing_video_ids_for(ids)
      return Set.new if ids.blank?

      by_external_id = Video.where(author: user, external_source: "youtube", external_id: ids)
                            .where.not(external_id: nil)
                            .pluck(:external_id)
      by_video_external_id = Video.where(author: user, video_provider: "youtube", video_external_id: ids)
                                  .where.not(video_external_id: nil)
                                  .pluck(:video_external_id)
      Set.new(by_external_id + by_video_external_id)
    end

    def find_default_category
      @find_default_category ||= begin
        if category_slug.present?
          user.categories.find_by(slug: category_slug)
        else
          user.categories.find_by(slug: "media") ||
            user.categories.find_by(category_type: "videos") ||
            user.categories.first
        end
      end
    end

    def parse_published_at(entry)
      upload_date = entry["upload_date"].to_s
      if upload_date.match?(/\A\d{8}\z/)
        return Time.zone.local(
          upload_date[0..3].to_i,
          upload_date[4..5].to_i,
          upload_date[6..7].to_i
        )
      end

      ts = entry["release_timestamp"] || entry["timestamp"] || entry["published_at"]
      if ts.is_a?(String) && ts.match?(/\A\d{4}-\d{2}-\d{2}/)
        return Time.zone.parse(ts)
      end
      return Time.zone.at(ts.to_i) if ts.present?

      Time.current
    rescue ArgumentError
      Time.current
    end

    def best_thumbnail_url(entry)
      thumbs = Array(entry["thumbnails"]).compact
      return entry["thumbnail"] if thumbs.empty?

      candidate = thumbs.max_by { |thumb| thumb["width"].to_i * thumb["height"].to_i }
      candidate&.dig("url") || entry["thumbnail"]
    end

    def upsert_translated_value(current_value, new_value)
      hash = current_value.is_a?(Hash) ? current_value.dup : {}
      hash[locale] = new_value
      hash
    end

    def normalize_channel_url(url)
      normalized = url.to_s.strip
      normalized = "https://#{normalized}" unless normalized.start_with?("http://", "https://")
      normalized.end_with?("/videos") ? normalized : "#{normalized}/videos"
    end

    def normalize_entry(entry)
      return entry if entry["id"].present?

      # Supports records from custom exporter json/jsonl.
      {
        "id" => entry["video_id"],
        "title" => entry["title"],
        "description" => entry["description"],
        "channel" => entry["channel"],
        "channel_id" => entry["channel_id"],
        "channel_url" => entry["channel_url"],
        "uploader" => entry["channel"],
        "uploader_id" => entry["channel_id"],
        "view_count" => entry["view_count"],
        "like_count" => entry["like_count"],
        "comment_count" => entry["comment_count"],
        "duration" => entry["duration_seconds"],
        "duration_string" => entry["duration_string"],
        "upload_date" => normalize_upload_date_to_yyyymmdd(entry["upload_date"]),
        "release_timestamp" => entry["published_at"],
        "timestamp" => nil,
        "live_status" => entry["live_status"],
        "was_live" => entry["was_live"],
        "playable_in_embed" => entry["playable_in_embed"],
        "availability" => entry["availability"],
        "webpage_url" => entry["video_url"],
        "thumbnail" => entry["thumbnail_url"],
        "thumbnails" => entry["thumbnails"],
        "thumbnail_local_path" => entry["thumbnail_local_path"],
        "language" => entry["language"],
        "tags" => entry["tags"] || [],
        "categories" => entry["categories"] || []
      }
    end

    def process_entry(entry, index, total, stats)
      video_id = entry["id"] || entry["video_id"]
      result = upsert_video_from_entry(entry)
      stats[result] += 1
      stats[:processed] += 1
      write_snapshot_line(
        kind: "video",
        index: index,
        total: total,
        result: result,
        video_id: video_id,
        captured_at: Time.current.utc.iso8601,
        payload: normalize_entry(entry)
      )

      emit_progress(:progress,
        index: index,
        total: total,
        percent: progress_percent(index, total),
        video_id: video_id,
        result: result,
        stats: stats.dup) if should_emit_progress?(index, total)
    rescue StandardError => e
      stats[:errors] += 1
      logger.error("[YouTube Sync] Failed to import entry #{video_id}: #{e.message}")
      write_snapshot_line(
        kind: "error",
        index: index,
        total: total,
        video_id: video_id,
        message: e.message,
        captured_at: Time.current.utc.iso8601
      )
      emit_progress(:error, video_id: video_id, message: e.message, stats: stats.dup)
    end

    def should_emit_progress?(current, total)
      return true if current == 1
      return true if total.present? && current == total

      (current % progress_every).zero?
    end

    def progress_percent(current, total)
      return nil if total.to_i <= 0

      ((current.to_f / total.to_f) * 100).round(1)
    end

    def emit_progress(event, payload = {})
      progress&.call(event, payload)
    rescue StandardError => e
      logger.warn("[YouTube Sync] Progress callback failed: #{e.message}")
    end

    def run_command(*command, phase_name: nil)
      started_at = Time.current
      heartbeat_thread = nil

      if phase_name.present?
        heartbeat_thread = Thread.new do
          loop do
            sleep 5
            elapsed = (Time.current - started_at).to_i
            emit_progress(:phase_heartbeat, phase: phase_name, elapsed_s: elapsed)
          end
        rescue StandardError
          nil
        end
      end

      result = Timeout.timeout(command_timeout) do
        Open3.capture3(*command)
      end
      result
    rescue Timeout::Error
      raise "Command timed out after #{command_timeout}s: #{command.join(" ")}"
    ensure
      if heartbeat_thread&.alive?
        heartbeat_thread.kill
        heartbeat_thread.join(0.1)
      end
    end

    def load_entries_from_file(path)
      unless File.exist?(path)
        raise "YouTube payload file not found: #{path}"
      end
      return load_entries_from_jsonl(path) if path.end_with?(".jsonl")

      parsed = JSON.parse(File.read(path))
      if parsed.is_a?(Hash) && parsed["entries"].is_a?(Array)
        parsed["entries"].compact
      elsif parsed.is_a?(Hash) && parsed["videos"].is_a?(Array)
        parsed["videos"].compact
      elsif parsed.is_a?(Array)
        parsed.compact
      else
        []
      end
    rescue JSON::ParserError => e
      raise "Invalid JSON in #{path}: #{e.message}"
    end

    def load_entries_from_jsonl(path)
      entries = []
      File.foreach(path) do |line|
        next if line.strip.blank?
        entries << JSON.parse(line)
      rescue JSON::ParserError => e
        logger.warn("[YouTube Sync] Skipping malformed JSONL line in #{path}: #{e.message}")
      end
      entries
    end

    def unchanged_video?(video, created:, youtube_payload:, title:, description:, published_at:)
      return false if created

      stored_signature = video.video_data.dig("youtube", "source_signature")
      localized_title = video.title_i18n.is_a?(Hash) ? video.title_i18n[locale] : nil
      localized_description = video.description_i18n.is_a?(Hash) ? video.description_i18n[locale] : nil

      stored_signature == youtube_payload["source_signature"] &&
        localized_title.to_s == title.to_s &&
        localized_description.to_s == description.to_s &&
        video.published_at.to_i == published_at.to_i
    end

    def generated_slug(title, video_id)
      base = sanitize_slug_fragment(title.to_s.parameterize(separator: "-"))
      base = "video" if base.blank?
      checksum = Digest::SHA1.hexdigest(video_id.to_s)[0, 8]
      "#{base}-#{checksum}"
    end

    def slug_for_video(video, title, video_id)
      existing = sanitize_slug_fragment(video.slug.to_s)
      return existing if existing.present?

      generated_slug(title, video_id)
    end

    def normalize_upload_date_to_yyyymmdd(date_value)
      return nil if date_value.blank?

      parsed = Date.parse(date_value.to_s)
      parsed.strftime("%Y%m%d")
    rescue ArgumentError
      nil
    end

    def resolve_local_thumbnail_path(path)
      return nil if path.blank?
      return path if Pathname.new(path).absolute?

      base_candidate = File.expand_path(path, thumbnail_base_dir)
      return base_candidate if File.exist?(base_candidate)

      root_candidate = Rails.root.join(path).to_s
      return root_candidate if File.exist?(root_candidate)

      nil
    end

    def yt_dlp_cookie_args
      return [] if cookies_path.blank?

      [ "--cookies", cookies_path.to_s ]
    end

    def metadata_extractor_args(auth_client_fallback: false)
      return "youtube:approximate_date" unless auth_client_fallback

      # Some age-restricted videos expose metadata only for selected clients.
      "youtube:approximate_date;player_client=android,web,web_creator,tv_embedded"
    end

    def rate_limited_error?(message)
      text = message.to_s.downcase
      text.include?("rate-limited") || text.include?("this content isn't available, try again later")
    end

    def format_unavailable_error?(message)
      message.to_s.downcase.include?("requested format is not available")
    end

    def age_restricted_error?(message)
      text = message.to_s.downcase
      text.include?("sign in to confirm your age") || text.include?("age-restricted")
    end

    def metadata_fetch_error_message(video_id, stderr)
      stderr_text = stderr.to_s.strip
      return "Skipped video #{video_id}: age-restricted on YouTube (authentication required)" if age_restricted_error?(stderr_text)

      first_line = stderr_text.lines.first.to_s.strip
      compact = first_line.presence || stderr_text
      "Failed to fetch video #{video_id}: #{compact}"
    end

    def sanitize_slug_fragment(value)
      value.to_s
        .downcase
        .tr("_", "-")
        .gsub(/[^a-z0-9\-]/, "")
        .gsub(/-+/, "-")
        .gsub(/\A-+|-+\z/, "")
    end

    def prepare_snapshot_file!
      return if snapshot_jsonl_path.blank?

      FileUtils.mkdir_p(File.dirname(snapshot_jsonl_path))
      @snapshot_io = File.open(snapshot_jsonl_path, "w:utf-8")
      emit_progress(:snapshot, path: snapshot_jsonl_path)
    end

    def write_snapshot_line(data)
      return unless @snapshot_io

      @snapshot_io.puts(JSON.generate(data))
      @snapshot_io.flush
    end

    def close_snapshot_file!
      return unless @snapshot_io

      @snapshot_io.close unless @snapshot_io.closed?
      @snapshot_io = nil
    end
  end
end
