# frozen_string_literal: true

require "rails_helper"

RSpec.describe YoutubeCredentials do
  let(:user) { create(:user) }
  let(:cookies_body) do
    <<~COOKIES
      # Netscape HTTP Cookie File
      .youtube.com	TRUE	/	TRUE	1999999999	SID	example-sid
      .youtube.com	TRUE	/	TRUE	1999999999	HSID	example-hsid
    COOKIES
  end

  describe "#youtube_cookies_configured?" do
    it "is false when ciphertext is blank" do
      expect(user.youtube_cookies_configured?).to be false
    end

    it "is true once cookies are stored" do
      user.store_youtube_cookies!(cookies_body)
      expect(user.youtube_cookies_configured?).to be true
    end
  end

  describe "#store_youtube_cookies!" do
    it "encrypts ciphertext, stores a checksum and age confirmation timestamp" do
      freeze_time = Time.utc(2026, 4, 1, 12, 0, 0)
      user.store_youtube_cookies!(cookies_body, age_confirmed_at: freeze_time)
      user.reload

      expect(user.youtube_cookies_ciphertext).to be_present
      expect(user.youtube_cookies_ciphertext).not_to include("SID")
      expect(user.youtube_cookies_checksum).to be_present
      expect(user.youtube_cookies_checksum.size).to eq(16)
      expect(user.youtube_age_confirmed_at.to_i).to eq(freeze_time.to_i)
    end

    it "rejects bodies that do not reference youtube.com" do
      expect {
        user.store_youtube_cookies!("# bogus\n.example.com\tTRUE\t/\tTRUE\t1\tSID\tabc")
      }.to raise_error(ArgumentError, /invalid cookies export/)
    end

    it "rejects blank bodies" do
      expect { user.store_youtube_cookies!("") }.to raise_error(ArgumentError)
    end
  end

  describe "#clear_youtube_cookies!" do
    it "removes ciphertext, checksum and age confirmation" do
      user.store_youtube_cookies!(cookies_body)
      user.clear_youtube_cookies!
      user.reload

      expect(user.youtube_cookies_ciphertext).to be_nil
      expect(user.youtube_cookies_checksum).to be_nil
      expect(user.youtube_age_confirmed_at).to be_nil
    end
  end

  describe "#with_youtube_cookies_file" do
    it "yields nil when no cookies are stored" do
      yielded = :sentinel
      user.with_youtube_cookies_file { |path| yielded = path }
      expect(yielded).to be_nil
    end

    it "yields a readable path with decrypted cookies and deletes it afterwards" do
      user.store_youtube_cookies!(cookies_body)

      captured_path = nil
      user.with_youtube_cookies_file do |path|
        captured_path = path
        expect(path).to be_present
        expect(File.exist?(path)).to be true
        expect(File.read(path)).to include("youtube.com")
        expect(File.stat(path).mode & 0o777).to eq(0o600)
      end

      expect(File.exist?(captured_path)).to be false
    end

    it "yields nil when stored ciphertext cannot be decrypted" do
      user.update_columns(youtube_cookies_ciphertext: "not-real-cipher")

      yielded = :sentinel
      user.with_youtube_cookies_file { |path| yielded = path }
      expect(yielded).to be_nil
    end
  end
end
