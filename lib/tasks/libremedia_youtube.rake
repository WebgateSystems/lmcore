# frozen_string_literal: true

require "json"
require "open3"
require "fileutils"

namespace :libremedia do
  desc "Sync YouTube videos for Ayder blog"
  task sync_ayder_youtube: :environment do
    user = User.find_by!(email: "ayder@gmail.com")
    channel_url = SiteSetting.get("youtube_url", user: user, default: "https://www.youtube.com/@AyderMuzhdabaev")
    download_thumbnails = ENV["YT_DOWNLOAD_THUMBNAILS"] == "1"
    playlist_items = ENV["YT_PLAYLIST_ITEMS"]
    source_json_path = ENV["YT_SOURCE_JSON"]
    thumbnail_base_dir = ENV["YT_THUMBNAIL_BASE_DIR"]
    snapshot_jsonl_path = ENV["YT_SNAPSHOT_JSONL"].presence || (source_json_path.blank? ? "tmp/youtube-sync/#{user.username}-live.jsonl" : nil)
    retry_limit = ENV["YT_RETRY_LIMIT"]
    retry_base_delay = ENV["YT_RETRY_BASE_DELAY"]
    sleep_requests = ENV["YT_SLEEP_REQUESTS"]

    progress_state = { line_length: 0, total: nil }
    render_progress = lambda do |payload|
      total = payload[:total].to_i
      index = payload[:index].to_i
      percent = payload[:percent] || (total.positive? ? ((index.to_f / total) * 100).round(1) : 0.0)
      bar_width = 28
      filled = total.positive? ? ((index.to_f / total) * bar_width).round : 0
      filled = 0 if filled.negative?
      filled = bar_width if filled > bar_width
      bar = "#{"=" * filled}#{"-" * (bar_width - filled)}"
      stats = payload[:stats] || {}
      line = "[#{bar}] #{index}/#{total} #{percent}% | created: #{stats[:created] || 0} updated: #{stats[:updated] || 0} skipped: #{stats[:skipped] || 0} errors: #{stats[:errors] || 0} | #{payload[:video_id]}"
      print "\r#{line}"
      if progress_state[:line_length] > line.length
        print(" " * (progress_state[:line_length] - line.length))
      end
      progress_state[:line_length] = line.length
      $stdout.flush
    end

    cookies_path_override = ENV["YT_COOKIES_FILE"].presence
    result = nil
    run_sync = lambda do |cookies_path|
      result = Youtube::ChannelVideosSyncService.new(
        user: user,
        channel_url: channel_url,
        locale: "uk",
        category_slug: "media",
        progress_every: 20,
        download_thumbnails: download_thumbnails,
        playlist_items: playlist_items,
        source_json_path: source_json_path,
        thumbnail_base_dir: thumbnail_base_dir,
        snapshot_jsonl_path: snapshot_jsonl_path,
        retry_limit: retry_limit,
        retry_base_delay: retry_base_delay,
        sleep_requests: sleep_requests,
        cookies_path: cookies_path,
        progress: lambda do |event, payload|
          case event
          when :start
            puts "[YouTube] Start user=#{payload[:user_id]} channel=#{payload[:channel_url]} thumbs=#{payload[:download_thumbnails]} playlist_items=#{payload[:playlist_items] || 'all'} source_json=#{payload[:source_json_path] || '-'} snapshot=#{payload[:snapshot_jsonl_path] || '-'} thumb_base=#{payload[:thumbnail_base_dir]} sleep_requests=#{payload[:sleep_requests]} retries=#{payload[:retry_limit]} youtube_auth=#{payload[:youtube_auth] ? 'yes' : 'no'}"
          when :snapshot
            puts "[YouTube] Snapshot JSONL => #{payload[:path]}"
          when :phase
            puts "[YouTube] Phase=#{payload[:name]}"
          when :phase_heartbeat
            puts "[YouTube] ...phase=#{payload[:phase]} elapsed=#{payload[:elapsed_s]}s" if payload[:phase] == "fetch_video_ids"
          when :discovered
            progress_state[:total] = payload[:total].to_i
            puts "[YouTube] Found #{payload[:total]} videos"
          when :metadata_progress
            puts "[YouTube] Metadata #{payload[:index]}/#{payload[:total]} video=#{payload[:video_id]}" if (payload[:index].to_i % 50).zero? || payload[:index].to_i == 1
          when :progress
            render_progress.call(payload)
          when :error
            print "\n"
            puts "[YouTube] ERROR video_id=#{payload[:video_id]} message=#{payload[:message]}"
          when :bot_check
            print "\n"
            puts "[YouTube] BOT CHECK video_id=#{payload[:video_id]} attempt=#{payload[:attempt]} trying=#{payload[:next_clients]}"
          when :rate_limited
            print "\n"
            puts "[YouTube] RATE LIMIT video_id=#{payload[:video_id]} attempt=#{payload[:attempt]} sleep=#{payload[:sleep_seconds]}s"
          when :finish
            print "\n"
            puts "[YouTube] Finished: #{payload[:stats]}"
          end
        end
      ).call
    end

    if cookies_path_override
      run_sync.call(cookies_path_override)
    else
      user.with_youtube_cookies_file { |path| run_sync.call(path) }
    end

    puts "Ayder YouTube sync completed: #{result}"
  end

  desc "Sync YouTube videos for a specific user by id"
  task :sync_youtube_channel, %i[user_id channel_url locale category_slug] => :environment do |_task, args|
    progress_state = { line_length: 0, total: nil }
    render_progress = lambda do |payload|
      total = payload[:total].to_i
      index = payload[:index].to_i
      percent = payload[:percent] || (total.positive? ? ((index.to_f / total) * 100).round(1) : 0.0)
      bar_width = 28
      filled = total.positive? ? ((index.to_f / total) * bar_width).round : 0
      filled = 0 if filled.negative?
      filled = bar_width if filled > bar_width
      bar = "#{"=" * filled}#{"-" * (bar_width - filled)}"
      stats = payload[:stats] || {}
      line = "[#{bar}] #{index}/#{total} #{percent}% | created: #{stats[:created] || 0} updated: #{stats[:updated] || 0} skipped: #{stats[:skipped] || 0} errors: #{stats[:errors] || 0} | #{payload[:video_id]}"
      print "\r#{line}"
      if progress_state[:line_length] > line.length
        print(" " * (progress_state[:line_length] - line.length))
      end
      progress_state[:line_length] = line.length
      $stdout.flush
    end

    user = User.find(args[:user_id])
    channel_url = args[:channel_url].presence || SiteSetting.get("youtube_url", user: user, default: nil)
    download_thumbnails = ENV["YT_DOWNLOAD_THUMBNAILS"] == "1"
    playlist_items = ENV["YT_PLAYLIST_ITEMS"]
    source_json_path = ENV["YT_SOURCE_JSON"]
    thumbnail_base_dir = ENV["YT_THUMBNAIL_BASE_DIR"]
    snapshot_jsonl_path = ENV["YT_SNAPSHOT_JSONL"].presence || (source_json_path.blank? ? "tmp/youtube-sync/user-#{user.id}-live.jsonl" : nil)
    retry_limit = ENV["YT_RETRY_LIMIT"]
    retry_base_delay = ENV["YT_RETRY_BASE_DELAY"]
    sleep_requests = ENV["YT_SLEEP_REQUESTS"]

    raise "channel_url argument or site setting 'youtube_url' is required" if channel_url.blank?

    cookies_path_override = ENV["YT_COOKIES_FILE"].presence
    result = nil
    run_sync = lambda do |cookies_path|
      result = Youtube::ChannelVideosSyncService.new(
        user: user,
        channel_url: channel_url,
        locale: args[:locale],
        category_slug: args[:category_slug],
        progress_every: 20,
        download_thumbnails: download_thumbnails,
        playlist_items: playlist_items,
        source_json_path: source_json_path,
        thumbnail_base_dir: thumbnail_base_dir,
        snapshot_jsonl_path: snapshot_jsonl_path,
        retry_limit: retry_limit,
        retry_base_delay: retry_base_delay,
        sleep_requests: sleep_requests,
        cookies_path: cookies_path,
        progress: lambda do |event, payload|
          case event
          when :start
            puts "[YouTube] Start user=#{payload[:user_id]} channel=#{payload[:channel_url]} thumbs=#{payload[:download_thumbnails]} playlist_items=#{payload[:playlist_items] || 'all'} source_json=#{payload[:source_json_path] || '-'} snapshot=#{payload[:snapshot_jsonl_path] || '-'} thumb_base=#{payload[:thumbnail_base_dir]} sleep_requests=#{payload[:sleep_requests]} retries=#{payload[:retry_limit]} youtube_auth=#{payload[:youtube_auth] ? 'yes' : 'no'}"
          when :snapshot
            puts "[YouTube] Snapshot JSONL => #{payload[:path]}"
          when :phase
            puts "[YouTube] Phase=#{payload[:name]}"
          when :phase_heartbeat
            puts "[YouTube] ...phase=#{payload[:phase]} elapsed=#{payload[:elapsed_s]}s" if payload[:phase] == "fetch_video_ids"
          when :discovered
            progress_state[:total] = payload[:total].to_i
            puts "[YouTube] Found #{payload[:total]} videos"
          when :metadata_progress
            puts "[YouTube] Metadata #{payload[:index]}/#{payload[:total]} video=#{payload[:video_id]}" if (payload[:index].to_i % 50).zero? || payload[:index].to_i == 1
          when :progress
            render_progress.call(payload)
          when :error
            print "\n"
            puts "[YouTube] ERROR video_id=#{payload[:video_id]} message=#{payload[:message]}"
          when :bot_check
            print "\n"
            puts "[YouTube] BOT CHECK video_id=#{payload[:video_id]} attempt=#{payload[:attempt]} trying=#{payload[:next_clients]}"
          when :rate_limited
            print "\n"
            puts "[YouTube] RATE LIMIT video_id=#{payload[:video_id]} attempt=#{payload[:attempt]} sleep=#{payload[:sleep_seconds]}s"
          when :finish
            print "\n"
            puts "[YouTube] Finished: #{payload[:stats]}"
          end
        end
      ).call
    end

    if cookies_path_override
      run_sync.call(cookies_path_override)
    else
      user.with_youtube_cookies_file { |path| run_sync.call(path) }
    end

    puts "YouTube sync completed for user #{user.id}: #{result}"
  end

  desc "Inspect which fields YouTube tab payload contains"
  task :probe_youtube_payload, %i[channel_url] => :environment do |_task, args|
    channel_url = args[:channel_url].presence || "https://www.youtube.com/@AyderMuzhdabaev/videos"
    stdout, stderr, status = Open3.capture3(
      "yt-dlp",
      "--dump-single-json",
      "--skip-download",
      "--no-warnings",
      "--playlist-items", "1",
      channel_url
    )
    raise "yt-dlp failed: #{stderr}" unless status.success?

    payload = JSON.parse(stdout)
    entry = Array(payload["entries"]).first || {}
    keys = entry.keys.sort

    puts "Channel: #{channel_url}"
    puts "Entry keys count: #{keys.size}"
    puts "Sample keys: #{keys.first(30).join(', ')}"
    puts "title=#{entry['title'].present?} description=#{entry['description'].present?} "\
         "upload_date=#{entry['upload_date'].present?} view_count=#{entry['view_count'].present?} "\
         "like_count=#{entry['like_count'].present?} comment_count=#{entry['comment_count'].present?} "\
         "duration=#{entry['duration'].present?} thumbnails=#{Array(entry['thumbnails']).size}"
  end

  desc "Fetch YouTube channel payload to JSON file"
  task :fetch_youtube_payload, %i[channel_url output_path playlist_items] => :environment do |_task, args|
    channel_url = args[:channel_url].presence || "https://www.youtube.com/@AyderMuzhdabaev/videos"
    output_path = args[:output_path].presence || "tmp/yt-dlp-result.json"
    playlist_items = args[:playlist_items].presence

    command = [
      "yt-dlp",
      "--dump-single-json",
      "--skip-download",
      "--no-warnings"
    ]
    command += [ "--playlist-items", playlist_items ] if playlist_items
    command << channel_url

    stdout, stderr, status = Open3.capture3("bash", "-lc", command.shelljoin)
    raise "yt-dlp failed: #{stderr}" unless status.success?

    FileUtils.mkdir_p(File.dirname(output_path))
    File.write(output_path, stdout)
    puts "Saved payload to #{output_path} (#{stdout.bytesize} bytes)"
  end

  desc "One-shot: backfill local thumbnails for YouTube videos (optional arg: user_id)"
  task :backfill_youtube_thumbnails, [ :user_id ] => :environment do |_task, args|
    interrupted = false
    previous_int_handler = trap("INT") { interrupted = true }
    previous_term_handler = trap("TERM") { interrupted = true }

    scope = Video.where(video_provider: "youtube")
    scope = scope.where(author_id: args[:user_id]) if args[:user_id].present?

    pending = scope.where(thumbnail: [ nil, "" ])
    total = pending.count
    puts "YouTube thumbnail backfill: scope=#{args[:user_id].present? ? "user=#{args[:user_id]}" : "all users"} pending=#{total}"
    next puts("Nothing to do.") if total.zero?

    started_at = Time.current
    progress = lambda do |event, payload|
      case event
      when :progress
        stats = payload[:stats] || {}
        processed = stats[:processed].to_i
        total_items = stats[:total].to_i
        percent = total_items.positive? ? ((processed.to_f / total_items) * 100).round(1) : 100.0
        remaining_items = [ total_items - processed, 0 ].max
        elapsed = [ (Time.current - started_at).to_f, 0.1 ].max
        per_second = processed / elapsed
        eta = per_second.positive? ? (remaining_items / per_second).round : nil

        line = "progress #{processed}/#{total_items} (#{percent}%) | updated=#{stats[:updated]} skipped=#{stats[:skipped]} failed=#{stats[:failed]} remaining=#{remaining_items}"
        line += " | eta=#{eta}s" if eta
        print "\r#{line.ljust(140)}"
        $stdout.flush
      when :error
        print "\n"
        puts "thumbnail error video_id=#{payload[:video_id]} message=#{payload[:message]}"
      when :finish
        print "\n"
      when :cancelled
        print "\n"
        puts "Cancellation requested. Stopping after current item..."
      end
    end

    result = Youtube::ThumbnailBackfillService.new(
      scope: pending,
      logger: Rails.logger,
      progress: progress,
      stop_requested: -> { interrupted }
    ).call(return_stats: true)
    remaining = pending.where(thumbnail: [ nil, "" ]).count

    puts "Backfill done: processed=#{result[:processed]}, updated=#{result[:updated]}, skipped=#{result[:skipped]}, failed=#{result[:failed]}, remaining_without_thumbnail=#{remaining}"
  ensure
    trap("INT", previous_int_handler) if previous_int_handler
    trap("TERM", previous_term_handler) if previous_term_handler
  end
end
