# frozen_string_literal: true

require "json"
require "open3"
require "timeout"
require "tmpdir"

module Youtube
  class CreatePostFromVideoSubtitlesService
    DEFAULT_TIMEOUT = 180

    attr_reader :user, :video, :progress, :command_timeout, :cookies_path

    def initialize(user:, video:, progress: nil, command_timeout: DEFAULT_TIMEOUT, cookies_path: nil)
      @user = user
      @video = video
      @progress = progress
      @command_timeout = command_timeout
      @cookies_path = cookies_path.to_s.strip.presence
    end

    def call
      emit(:phase, stage: "prepare")

      existing_post = user.posts.kept.find_by(video_id: video.id)
      if existing_post
        emit(:finish, result: "skipped", post_id: existing_post.id)
        return { result: :skipped, post: existing_post }
      end

      metadata = fetch_video_metadata
      language = resolve_original_language(metadata)
      emit(:phase, stage: "download_subtitles", language: language)

      transcript = fetch_transcript(language)
      transcript = fallback_transcript if transcript.blank?
      raise "Subtitles were not found for this video" if transcript.blank?

      emit(:phase, stage: "create_post")
      post = create_draft_post(transcript: transcript, language: language)
      emit(:finish, result: "created", post_id: post.id)

      { result: :created, post: post }
    end

    private

    def emit(event, payload = {})
      progress&.call(event, payload)
    rescue StandardError
      nil
    end

    def fetch_video_metadata
      stdout, stderr, status = run_command(
        "yt-dlp",
        "--dump-json",
        "--skip-download",
        "--ignore-no-formats-error",
        "--no-warnings",
        *yt_dlp_cookie_args,
        youtube_url
      )
      raise "Failed to fetch video metadata: #{stderr}" unless status.success?

      JSON.parse(stdout)
    end

    def resolve_original_language(metadata)
      language = metadata["language"].presence
      return normalize_language(language) if language.present?

      subtitle_lang = metadata.fetch("subtitles", {}).keys.first ||
                      metadata.fetch("automatic_captions", {}).keys.first
      normalize_language(subtitle_lang || I18n.default_locale.to_s)
    end

    def fetch_transcript(language)
      Dir.mktmpdir("yt-subtitles-") do |dir|
        output_template = File.join(dir, "%(id)s.%(ext)s")
        stdout, stderr, status = run_command(
          "yt-dlp",
          "--skip-download",
          "--allow-unplayable-formats",
          "--format", YtDlpDefaults::FORMAT_SELECTOR,
          "--write-sub",
          "--write-auto-sub",
          "--sub-format", "vtt",
          "--sub-langs", language,
          "--output", output_template,
          *yt_dlp_cookie_args,
          youtube_url
        )
        raise "Failed to download subtitles: #{stderr.presence || stdout}" unless status.success?

        files = Dir.glob(File.join(dir, "#{video.video_external_id}*.vtt"))
        return "" if files.empty?

        parse_vtt(File.read(files.first))
      end
    end

    def parse_vtt(content)
      cleaned_lines = content.to_s
        .lines
        .map(&:strip)
        .reject do |line|
          line.blank? ||
            line == "WEBVTT" ||
            line.start_with?("NOTE") ||
            line.match?(/\AKind:/i) ||
            line.match?(/\ALanguage:/i) ||
            line.match?(/\A\d+\z/) ||
            line.match?(/\A\d{2}:\d{2}:\d{2}\.\d{3}\s-->\s\d{2}:\d{2}:\d{2}\.\d{3}/) ||
            line.match?(/\A\d{2}:\d{2}\.\d{3}\s-->\s\d{2}:\d{2}\.\d{3}/)
        end
        .map { |line| line.gsub(/<[^>]*>/, "").strip }

      deduped_lines = []
      previous_normalized = nil

      cleaned_lines.each do |line|
        normalized = line.downcase.gsub(/\s+/, " ").strip
        next if normalized.blank? || normalized == previous_normalized

        deduped_lines << line
        previous_normalized = normalized
      end

      deduped_lines.join("\n").squeeze("\n").strip
    end

    def fallback_transcript
      locale = normalize_language(I18n.default_locale.to_s)
      descriptions = video.description_i18n.is_a?(Hash) ? video.description_i18n : {}
      descriptions[locale].presence || descriptions.values.compact.first.to_s
    end

    def create_draft_post(transcript:, language:)
      title = "#{video.title} - transcript"
      post = user.posts.new(
        status: "draft",
        category: video.category,
        video: video,
        external_source: "youtube",
        external_id: video.video_external_id,
        published_at: nil
      )
      post.title_i18n = { language => title }
      post.content_i18n = { language => transcript }
      post.subtitle_i18n = { language => video.title.to_s }
      post.lead_i18n = { language => "Draft created from YouTube subtitles." }
      post.save!
      post
    end

    def youtube_url
      return video.watch_url if video.video_external_id.present?

      video.video_url
    end

    def yt_dlp_cookie_args
      return [] if cookies_path.blank?

      [ "--cookies", cookies_path.to_s ]
    end

    def run_command(*command)
      Timeout.timeout(command_timeout) do
        Open3.capture3(*command)
      end
    rescue Timeout::Error
      raise "Command timed out after #{command_timeout}s: #{command.join(" ")}"
    end

    def normalize_language(value)
      value.to_s.strip.downcase.gsub("_", "-")
    end
  end
end
