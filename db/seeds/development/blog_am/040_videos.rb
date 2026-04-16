# frozen_string_literal: true

ayder = User.find_by!(email: "ayder@gmail.com")

channel_url = SiteSetting.get("youtube_url", user: ayder, default: "https://www.youtube.com/@AyderMuzhdabaev")
log("  [Blog AM] Syncing videos from #{channel_url}...")

result = Youtube::ChannelVideosSyncService.new(
  user: ayder,
  channel_url: channel_url,
  locale: "uk",
  category_slug: "media",
  progress_every: 20,
  download_thumbnails: false,
  playlist_items: ENV["YT_PLAYLIST_ITEMS"],
  source_json_path: ENV["YT_SOURCE_JSON"],
  thumbnail_base_dir: ENV["YT_THUMBNAIL_BASE_DIR"],
  retry_limit: ENV["YT_RETRY_LIMIT"],
  retry_base_delay: ENV["YT_RETRY_BASE_DELAY"],
  sleep_requests: ENV["YT_SLEEP_REQUESTS"],
  progress: lambda do |event, payload|
    case event
    when :start
      log("  [Blog AM] YouTube sync started for user ##{payload[:user_id]} (thumbs=#{payload[:download_thumbnails]}, source_json=#{payload[:source_json_path] || '-'}, thumb_base=#{payload[:thumbnail_base_dir]}, sleep_requests=#{payload[:sleep_requests]}, retries=#{payload[:retry_limit]})")
    when :phase
      log("  [Blog AM] Phase: #{payload[:name]}")
    when :phase_heartbeat
      log("  [Blog AM] ... phase=#{payload[:phase]} elapsed=#{payload[:elapsed_s]}s")
    when :discovered
      log("  [Blog AM] Found #{payload[:total]} videos on channel")
    when :progress
      log("  [Blog AM] Progress #{payload[:index]}/#{payload[:total]} (#{payload[:percent]}%) result=#{payload[:result]} stats=#{payload[:stats]}")
    when :error
      log("  [Blog AM] ERROR video_id=#{payload[:video_id]}: #{payload[:message]}")
    when :rate_limited
      log("  [Blog AM] RATE LIMIT video_id=#{payload[:video_id]} attempt=#{payload[:attempt]} sleep=#{payload[:sleep_seconds]}s")
    when :finish
      log("  [Blog AM] Finished sync: #{payload[:stats]}")
    end
  end
).call

log("  [Blog AM] Synced videos: #{result[:processed]} processed, #{result[:created]} created, #{result[:updated]} updated, #{result[:errors]} errors")
