# frozen_string_literal: true

require "rails_helper"

# Targets the helper / branching surface inside `Youtube::ChannelVideosSyncService`
# that the higher-level happy-path spec does not exercise: published_at parsing
# fallbacks, slug generation, retry classification, snapshot writing, source
# file loading variants, etc.
RSpec.describe Youtube::ChannelVideosSyncService, type: :service do
  let(:author) { create(:user, :author, locale: "en") }
  let(:service) do
    described_class.new(user: author, channel_url: "https://youtube.com/@x/videos",
                        retry_base_delay: 0, sleep_requests: 0)
  end

  describe "channel URL normalization" do
    it "leaves http:// alone but still appends /videos" do
      svc = described_class.new(user: author, channel_url: "http://youtube.com/@foo")
      expect(svc.channel_url).to eq("http://youtube.com/@foo/videos")
    end
  end

  describe "#parse_published_at" do
    it "parses 8-digit upload_date strings" do
      ts = service.send(:parse_published_at, "upload_date" => "20240507")
      expect(ts.year).to eq(2024)
      expect(ts.month).to eq(5)
      expect(ts.day).to eq(7)
    end

    it "parses ISO release_timestamp strings" do
      ts = service.send(:parse_published_at, "release_timestamp" => "2024-07-08T10:00:00Z")
      expect(ts.year).to eq(2024)
    end

    it "falls back to numeric epoch for release_timestamp" do
      ts = service.send(:parse_published_at, "release_timestamp" => 1_700_000_000)
      expect(ts).to eq(Time.zone.at(1_700_000_000))
    end

    it "falls back to current time when nothing is parseable" do
      ts = service.send(:parse_published_at, {})
      expect(ts).to be_within(5.seconds).of(Time.current)
    end

    it "returns current time when upload_date is unparseable" do
      ts = service.send(:parse_published_at, "upload_date" => "not-a-date")
      expect(ts).to be_within(5.seconds).of(Time.current)
    end
  end

  describe "#best_thumbnail_url" do
    before do
      allow(service).to receive(:reachable_thumbnail_url?).and_return(false)
    end

    it "prefers deterministic YouTube URLs when available" do
      allow(service).to receive(:reachable_thumbnail_url?) do |url|
        url.include?("/maxresdefault.jpg")
      end

      url = service.send(:best_thumbnail_url, "id" => "abc123", "thumbnails" => [])
      expect(url).to eq("https://i.ytimg.com/vi/abc123/maxresdefault.jpg")
    end

    it "falls back to deterministic hq URL when maxres is unavailable" do
      allow(service).to receive(:reachable_thumbnail_url?) do |url|
        url.include?("/hqdefault.jpg")
      end

      url = service.send(:best_thumbnail_url, "id" => "abc123", "thumbnails" => [])
      expect(url).to eq("https://i.ytimg.com/vi/abc123/hqdefault.jpg")
    end

    it "picks the largest thumbnail by area" do
      url = service.send(:best_thumbnail_url, "thumbnails" => [
        { "url" => "small", "width" => 100, "height" => 100 },
        { "url" => "big",   "width" => 1280, "height" => 720 }
      ])
      expect(url).to eq("big")
    end

    it "ignores thumbnails without known dimensions" do
      url = service.send(:best_thumbnail_url, "thumbnails" => [
        { "url" => "unknown-size", "width" => nil, "height" => nil },
        { "url" => "known-size", "width" => 320, "height" => 180 }
      ])
      expect(url).to eq("known-size")
    end

    it "falls back to top-level thumbnail when array is empty" do
      url = service.send(:best_thumbnail_url, "thumbnails" => [], "thumbnail" => "fallback.jpg")
      expect(url).to eq("fallback.jpg")
    end
  end

  describe "#normalize_entry" do
    it "passes through entries that already have an id" do
      entry = { "id" => "abc", "title" => "X" }
      expect(service.send(:normalize_entry, entry)).to eq(entry)
    end

    it "remaps custom-exporter shape to the yt-dlp shape" do
      remapped = service.send(:normalize_entry,
        "video_id" => "xyz", "title" => "Hi", "channel" => "ch", "duration_seconds" => 42,
        "video_url" => "https://yt/xyz", "thumbnail_url" => "thumb.jpg", "tags" => [ "a" ])
      expect(remapped["id"]).to eq("xyz")
      expect(remapped["uploader"]).to eq("ch")
      expect(remapped["duration"]).to eq(42)
      expect(remapped["webpage_url"]).to eq("https://yt/xyz")
      expect(remapped["thumbnail"]).to eq("thumb.jpg")
      expect(remapped["tags"]).to eq([ "a" ])
    end
  end

  describe "#normalize_upload_date_to_yyyymmdd" do
    it "returns YYYYMMDD for parseable strings" do
      expect(service.send(:normalize_upload_date_to_yyyymmdd, "2024-05-07")).to eq("20240507")
    end

    it "returns nil for blank input" do
      expect(service.send(:normalize_upload_date_to_yyyymmdd, "")).to be_nil
    end

    it "returns nil for unparseable input" do
      expect(service.send(:normalize_upload_date_to_yyyymmdd, "not a date")).to be_nil
    end
  end

  describe "slug helpers" do
    it "generates an ASCII-safe slug from a title" do
      slug = service.send(:generated_slug, "Hello World!", "abcdef")
      expect(slug).to match(/\Ahello-world-[a-f0-9]{8}\z/)
    end

    it "falls back to 'video' when title parameterizes to empty" do
      slug = service.send(:generated_slug, "!!!", "abcdef")
      expect(slug).to start_with("video-")
    end

    it "keeps an existing slug if the video already has one" do
      video = Video.new(slug: "kept")
      slug = service.send(:slug_for_video, video, "Anything", "id")
      expect(slug).to eq("kept")
    end

    it "generates a fresh slug when video has no slug" do
      slug = service.send(:slug_for_video, Video.new, "Title", "id")
      expect(slug).to start_with("title-")
    end
  end

  describe "#progress_percent / #should_emit_progress?" do
    it "always emits at index 1, the final index, and every Nth index" do
      svc = described_class.new(user: author, channel_url: "https://youtube.com/@x/videos",
                                progress_every: 3)
      expect(svc.send(:should_emit_progress?, 1, 100)).to be true
      expect(svc.send(:should_emit_progress?, 100, 100)).to be true
      expect(svc.send(:should_emit_progress?, 6, 100)).to be true
      expect(svc.send(:should_emit_progress?, 7, 100)).to be false
    end

    it "returns nil for non-positive totals and a rounded percent otherwise" do
      expect(service.send(:progress_percent, 1, 0)).to be_nil
      expect(service.send(:progress_percent, 1, 4)).to eq(25.0)
    end
  end

  describe "error classification helpers" do
    it "classifies bot wall messages" do
      expect(service.send(:bot_check_error?, "Sign in to confirm you're not a bot")).to be true
      expect(service.send(:bot_check_error?, "all good")).to be false
    end

    it "classifies age-restricted messages" do
      expect(service.send(:age_restricted_error?, "Sign in to confirm your age")).to be true
      expect(service.send(:age_restricted_error?, "video is age-restricted")).to be true
      expect(service.send(:age_restricted_error?, "fine")).to be false
    end

    it "classifies rate-limited messages" do
      expect(service.send(:rate_limited_error?, "got rate-limited again")).to be true
      expect(service.send(:rate_limited_error?, "This content isn't available, try again later")).to be true
      expect(service.send(:rate_limited_error?, "fine")).to be false
    end

    it "classifies format-unavailable messages" do
      expect(service.send(:format_unavailable_error?, "Requested format is not available")).to be true
      expect(service.send(:format_unavailable_error?, "fine")).to be false
    end
  end

  describe "#metadata_fetch_error_message" do
    it "rewrites age-restricted stderr into a user-friendly message" do
      msg = service.send(:metadata_fetch_error_message, "vid1", "Sign in to confirm your age, please")
      expect(msg).to include("age-restricted")
    end

    it "uses the first line of generic stderr" do
      msg = service.send(:metadata_fetch_error_message, "vid1", "first line\nsecond line")
      expect(msg).to eq("Failed to fetch video vid1: first line")
    end
  end

  describe "#metadata_extractor_args / cookies / player_clients" do
    it "returns cookie args when a path is given, empty otherwise" do
      expect(service.send(:yt_dlp_cookie_args)).to eq([])
      svc = described_class.new(user: author, channel_url: "https://youtube.com/@x/videos",
                                cookies_path: "/tmp/c.txt")
      expect(svc.send(:yt_dlp_cookie_args)).to eq([ "--cookies", "/tmp/c.txt" ])
    end

    it "joins approximate_date with player_client when given" do
      args = service.send(:metadata_extractor_args, player_clients: %w[ios web_safari])
      expect(args).to eq("youtube:approximate_date;player_client=ios,web_safari")
    end

    it "omits player_client when none is given" do
      expect(service.send(:metadata_extractor_args, player_clients: nil)).to eq("youtube:approximate_date")
    end

    it "selects auth client list for :auth_client mode" do
      expect(service.send(:player_clients_for, :auth_client, 0)).to include("android")
    end

    it "selects bot bypass set by index" do
      sets = service.send(:bot_bypass_client_sets)
      expect(service.send(:player_clients_for, :bot_bypass, 0)).to eq(sets[0])
    end

    it "returns the last set when bot_fallback_index overshoots" do
      sets = service.send(:bot_bypass_client_sets)
      expect(service.send(:player_clients_for, :bot_bypass, sets.length + 5)).to eq(sets.last)
    end

    it "lifts the sticky preferred client set to index 0" do
      service.instance_variable_set(:@preferred_player_clients, %w[my custom])
      sets = service.send(:bot_bypass_client_sets)
      expect(sets.first).to eq(%w[my custom])
    end

    it "respects YT_PLAYER_CLIENTS env override" do
      ENV["YT_PLAYER_CLIENTS"] = "tv,android|ios"
      svc = described_class.new(user: author, channel_url: "https://youtube.com/@x/videos")
      expect(svc.send(:base_bot_bypass_client_sets)).to eq([ %w[tv android], %w[ios] ])
    ensure
      ENV.delete("YT_PLAYER_CLIENTS")
    end
  end

  describe "#emit_progress error swallowing" do
    it "logs but does not raise when the callback explodes" do
      logger = instance_double(Logger, info: nil, warn: nil, error: nil)
      svc = described_class.new(user: author, channel_url: "https://youtube.com/@x/videos",
                                progress: ->(*) { raise "explode" }, logger: logger)
      expect { svc.send(:emit_progress, :start, {}) }.not_to raise_error
      expect(logger).to have_received(:warn).with(/Progress callback failed/)
    end
  end

  describe "#load_entries_from_file" do
    it "raises a friendly error when the file is missing" do
      expect { service.send(:load_entries_from_file, "/no/such/path.json") }
        .to raise_error(/payload file not found/)
    end

    it "returns the array directly when JSON is an array" do
      file = Tempfile.new([ "yt", ".json" ])
      file.write(JSON.generate([ { "id" => "x" } ]))
      file.flush
      expect(service.send(:load_entries_from_file, file.path)).to eq([ { "id" => "x" } ])
    ensure
      file.close
      file.unlink
    end

    it "extracts {entries: [...]} payloads" do
      file = Tempfile.new([ "yt", ".json" ])
      file.write(JSON.generate({ "entries" => [ { "id" => "a" } ] }))
      file.flush
      expect(service.send(:load_entries_from_file, file.path)).to eq([ { "id" => "a" } ])
    ensure
      file.close
      file.unlink
    end

    it "extracts {videos: [...]} payloads" do
      file = Tempfile.new([ "yt", ".json" ])
      file.write(JSON.generate({ "videos" => [ { "id" => "a" } ] }))
      file.flush
      expect(service.send(:load_entries_from_file, file.path)).to eq([ { "id" => "a" } ])
    ensure
      file.close
      file.unlink
    end

    it "raises a friendly error on invalid JSON" do
      file = Tempfile.new([ "yt", ".json" ])
      file.write("not-json")
      file.flush
      expect { service.send(:load_entries_from_file, file.path) }.to raise_error(/Invalid JSON/)
    ensure
      file.close
      file.unlink
    end

    it "loads JSONL by line, skipping malformed lines" do
      logger = instance_double(Logger, info: nil, warn: nil, error: nil)
      svc = described_class.new(user: author, channel_url: "https://youtube.com/@x/videos", logger: logger)
      file = Tempfile.new([ "yt", ".jsonl" ])
      file.write(JSON.generate({ "id" => "a" }) + "\n" + "garbage\n" + JSON.generate({ "id" => "b" }) + "\n")
      file.flush
      entries = svc.send(:load_entries_from_file, file.path)
      expect(entries.map { |e| e["id"] }).to eq(%w[a b])
      expect(logger).to have_received(:warn).with(/Skipping malformed JSONL line/)
    ensure
      file.close
      file.unlink
    end
  end

  describe "snapshot file lifecycle" do
    it "creates+writes+closes the snapshot file when a path is configured" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "snap.jsonl")
        svc = described_class.new(user: author, channel_url: "https://youtube.com/@x/videos",
                                  snapshot_jsonl_path: path)
        svc.send(:prepare_snapshot_file!)
        svc.send(:write_snapshot_line, kind: "video", video_id: "abc")
        svc.send(:close_snapshot_file!)

        line = File.readlines(path).first
        expect(JSON.parse(line)).to include("kind" => "video", "video_id" => "abc")
      end
    end

    it "is a no-op when no path is configured" do
      expect { service.send(:prepare_snapshot_file!) }.not_to raise_error
      expect { service.send(:write_snapshot_line, kind: "x") }.not_to raise_error
      expect { service.send(:close_snapshot_file!) }.not_to raise_error
    end
  end

  describe "#existing_video_ids_for" do
    it "returns an empty Set when input is blank" do
      expect(service.send(:existing_video_ids_for, [])).to be_a(Set)
      expect(service.send(:existing_video_ids_for, [])).to be_empty
    end

    it "matches by both external_id and video_external_id" do
      Video.create!(author: author, slug: "a", title_i18n: { "en" => "a" }, status: "published",
                    video_provider: "youtube", video_external_id: "vidA",
                    external_source: "youtube", external_id: "vidA")
      Video.create!(author: author, slug: "b", title_i18n: { "en" => "b" }, status: "published",
                    video_provider: "youtube", video_external_id: "vidB",
                    external_source: "other", external_id: nil)
      result = service.send(:existing_video_ids_for, %w[vidA vidB vidC])
      expect(result).to include("vidA", "vidB")
      expect(result).not_to include("vidC")
    end
  end

  describe "#unchanged_video?" do
    it "returns false for newly-created records" do
      payload = { "source_signature" => "sig" }
      expect(service.send(:unchanged_video?, Video.new, created: true,
        youtube_payload: payload, title: "t", description: "d", published_at: Time.current, translation_locale: service.locale)).to be false
    end

    it "returns true when signature, title, description and published_at all match" do
      published = Time.zone.local(2024, 1, 1)
      video = Video.new(
        title_i18n: { service.locale => "t" },
        description_i18n: { service.locale => "d" },
        video_data: { "youtube" => { "source_signature" => "sig" } },
        published_at: published
      )
      payload = { "source_signature" => "sig" }
      expect(service.send(:unchanged_video?, video, created: false,
        youtube_payload: payload, title: "t", description: "d", published_at: published, translation_locale: service.locale)).to be true
    end
  end

  describe "#resolve_local_thumbnail_path" do
    it "returns nil for blank input" do
      expect(service.send(:resolve_local_thumbnail_path, nil)).to be_nil
      expect(service.send(:resolve_local_thumbnail_path, "")).to be_nil
    end

    it "returns absolute paths verbatim" do
      expect(service.send(:resolve_local_thumbnail_path, "/abs/path.jpg")).to eq("/abs/path.jpg")
    end

    it "resolves relative paths under thumbnail_base_dir when present" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "thumb.jpg"), "fake")
        svc = described_class.new(user: author, channel_url: "https://youtube.com/@x/videos",
                                  thumbnail_base_dir: dir)
        expect(svc.send(:resolve_local_thumbnail_path, "thumb.jpg")).to eq(File.join(dir, "thumb.jpg"))
      end
    end

    it "returns nil when relative paths cannot be located" do
      expect(service.send(:resolve_local_thumbnail_path, "nope/notthere.jpg")).to be_nil
    end
  end

  describe "#fetch_video_metadata_with_retry classification" do
    it "retries with bot_bypass clients when the bot wall is hit" do
      stats = { processed: 0, errors: 0 }
      attempts = 0
      allow(service).to receive(:fetch_video_metadata) do
        attempts += 1
        if attempts == 1
          raise "Sign in to confirm you're not a bot"
        else
          { "id" => "abc" }
        end
      end
      result = service.send(:fetch_video_metadata_with_retry, "abc", 1, 1, stats)
      expect(result[:status]).to eq(:ok)
      expect(stats[:bot_bypass_fallbacks]).to be >= 1
    end

    it "marks age-restricted videos as :skipped" do
      stats = { processed: 0, errors: 0, age_auth_fallbacks: 0 }
      allow(service).to receive(:fetch_video_metadata).and_raise("Sign in to confirm your age")
      result = service.send(:fetch_video_metadata_with_retry, "abc", 1, 1, stats)
      expect(result[:status]).to eq(:skipped)
      expect(result[:reason]).to eq(:age_restricted)
    end

    it "retries on tolerant mode for format_unavailable errors" do
      stats = { processed: 0, errors: 0, format_fallbacks: 0 }
      attempts = 0
      allow(service).to receive(:fetch_video_metadata) do
        attempts += 1
        attempts == 1 ? raise("Requested format is not available") : { "id" => "abc" }
      end
      result = service.send(:fetch_video_metadata_with_retry, "abc", 1, 1, stats)
      expect(result[:status]).to eq(:ok)
      expect(stats[:format_fallbacks]).to eq(1)
    end

    it "returns :error and records to stats for unrecoverable errors" do
      stats = { processed: 0, errors: 0 }
      allow(service).to receive(:fetch_video_metadata).and_raise("totally unknown")
      result = service.send(:fetch_video_metadata_with_retry, "abc", 1, 1, stats)
      expect(result[:status]).to eq(:error)
    end
  end
end
