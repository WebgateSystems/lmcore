# frozen_string_literal: true

require "rails_helper"

RSpec.describe Youtube::CreatePostFromVideoSubtitlesService, type: :service do
  let(:author) { create(:user, :author) }
  let(:video) do
    create(:video,
      author: author,
      video_external_id: "abc123",
      video_url: "https://www.youtube.com/watch?v=abc123",
      title_i18n: { "en" => "Video title" },
      description_i18n: { "en" => "Desc body" })
  end
  let(:service) { described_class.new(user: author, video: video) }

  describe "#call (skipped path)" do
    it "returns :skipped when a kept post already references the video" do
      existing = create(:post, author: author, video: video, status: "draft")
      result = service.call
      expect(result[:result]).to eq(:skipped)
      expect(result[:post]).to eq(existing)
    end
  end

  describe "#parse_vtt" do
    it "strips WEBVTT headers, timestamps, cue numbers and inline tags" do
      content = <<~VTT
        WEBVTT
        Kind: captions
        Language: en

        1
        00:00:00.000 --> 00:00:01.500
        <v Speaker>Hello <c.yellow>world</c></v>

        2
        00:00:01.500 --> 00:00:02.500
        Second line.
      VTT
      result = service.send(:parse_vtt, content)
      expect(result).to include("Hello world")
      expect(result).to include("Second line.")
      expect(result).not_to include("WEBVTT")
      expect(result).not_to include("00:00")
      expect(result).not_to include("<v")
    end

    it "deduplicates consecutive identical lines" do
      content = "WEBVTT\n\n00:00:00.000 --> 00:00:01.000\nrepeat\n\n00:00:01.000 --> 00:00:02.000\nrepeat\n"
      result = service.send(:parse_vtt, content)
      expect(result.scan("repeat").size).to eq(1)
    end

    it "handles MM:SS.MMM short timestamps" do
      content = "WEBVTT\n\n00:00.000 --> 00:01.000\nshort form\n"
      result = service.send(:parse_vtt, content)
      expect(result).to eq("short form")
    end

    it "returns an empty string for blank input" do
      expect(service.send(:parse_vtt, "")).to eq("")
      expect(service.send(:parse_vtt, nil)).to eq("")
    end
  end

  describe "#resolve_original_language" do
    it "uses metadata['language'] when present" do
      result = service.send(:resolve_original_language, "language" => "EN_US")
      expect(result).to eq("en-us")
    end

    it "falls back to subtitles.keys.first" do
      result = service.send(:resolve_original_language,
        "subtitles" => { "uk" => [] }, "automatic_captions" => {})
      expect(result).to eq("uk")
    end

    it "falls back to automatic_captions.keys.first" do
      result = service.send(:resolve_original_language,
        "subtitles" => {}, "automatic_captions" => { "fr" => [] })
      expect(result).to eq("fr")
    end

    it "falls back to default I18n locale when nothing is present" do
      result = service.send(:resolve_original_language, {})
      expect(result).to eq(I18n.default_locale.to_s.downcase.gsub("_", "-"))
    end
  end

  describe "#youtube_url / #yt_dlp_cookie_args / #normalize_language" do
    it "returns the watch_url when an external id is present" do
      expect(service.send(:youtube_url)).to include("v=abc123")
    end

    it "falls back to video.video_url when external id is absent" do
      vid = build(:video, author: author, video_external_id: "", video_url: "https://example.com/raw")
      svc = described_class.new(user: author, video: vid)
      expect(svc.send(:youtube_url)).to eq("https://example.com/raw")
    end

    it "returns no cookie args by default and the right pair when configured" do
      expect(service.send(:yt_dlp_cookie_args)).to eq([])
      svc = described_class.new(user: author, video: video, cookies_path: "/tmp/c.txt")
      expect(svc.send(:yt_dlp_cookie_args)).to eq([ "--cookies", "/tmp/c.txt" ])
    end

    it "lower-cases and dash-normalizes language tags" do
      expect(service.send(:normalize_language, "EN_US")).to eq("en-us")
      expect(service.send(:normalize_language, "  PL  ")).to eq("pl")
      expect(service.send(:normalize_language, nil)).to eq("")
    end
  end

  describe "#fallback_transcript" do
    it "returns the description in the default locale when present" do
      I18n.with_locale(:en) do
        expect(service.send(:fallback_transcript)).to eq("Desc body")
      end
    end

    it "returns the first non-blank description when default-locale entry is missing" do
      vid = create(:video, author: author, description_i18n: { "fr" => "fr body" })
      svc = described_class.new(user: author, video: vid)
      I18n.with_locale(:en) do
        expect(svc.send(:fallback_transcript)).to eq("fr body")
      end
    end
  end

  describe "#emit error swallowing" do
    it "does not raise when the progress callback explodes" do
      svc = described_class.new(user: author, video: video, progress: ->(*) { raise "explode" })
      expect { svc.send(:emit, :phase) }.not_to raise_error
    end
  end

  describe "#call (subtitles fallback to description)" do
    it "creates the draft from the description when no transcript was downloaded" do
      ok = instance_double(Process::Status, success?: true)
      allow(service).to receive(:run_command).and_return([ '{"language":"en"}', "", ok ])
      allow(service).to receive(:fetch_transcript).and_return("")

      result = service.call
      expect(result[:result]).to eq(:created)
      expect(result[:post].content_i18n["en"]).to include("Desc body")
    end

    it "raises when neither subtitles nor a description exist" do
      vid = create(:video, author: author, description_i18n: {})
      svc = described_class.new(user: author, video: vid)
      ok = instance_double(Process::Status, success?: true)
      allow(svc).to receive(:run_command).and_return([ '{"language":"en"}', "", ok ])
      allow(svc).to receive(:fetch_transcript).and_return("")

      expect { svc.call }.to raise_error(/Subtitles were not found/)
    end
  end
end
