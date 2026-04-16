# frozen_string_literal: true

# Stores a Netscape-format cookies.txt export for YouTube so yt-dlp can access
# age-restricted and signed-in content. Ciphertext is derived with
# ActiveSupport::MessageEncryptor (AES-256-GCM + verifier).
#
# Callers must use +with_youtube_cookies_file+ so secrets are only ever passed as
# a filesystem path to yt-dlp (never in Sidekiq args, logs, or shell argv as raw text).
module YoutubeCredentials
  extend ActiveSupport::Concern

  COOKIES_KEY_CONTEXT = "user-youtube-netscape-cookies-v1"

  def youtube_cookies_configured?
    youtube_cookies_ciphertext.present?
  end

  def clear_youtube_cookies!
    update_columns(
      youtube_cookies_ciphertext: nil,
      youtube_cookies_checksum: nil,
      youtube_age_confirmed_at: nil,
      updated_at: Time.current
    )
  end

  # @param raw_text [String] Netscape cookies.txt body (must reference youtube.com)
  def store_youtube_cookies!(raw_text, age_confirmed_at: Time.current)
    normalized = normalize_netscape_cookies(raw_text)
    raise ArgumentError, "invalid cookies export" if normalized.blank?

    payload = encrypt_cookie_payload(normalized)
    update!(
      youtube_cookies_ciphertext: payload,
      youtube_cookies_checksum: Digest::SHA256.hexdigest(normalized)[0, 16],
      youtube_age_confirmed_at: age_confirmed_at
    )
  end

  # Yields a path to a chmod 600 temp cookies file, or nil. Deletes the temp tree after the block.
  def with_youtube_cookies_file
    unless youtube_cookies_ciphertext.present?
      yield nil
      return
    end

    plaintext = decrypt_cookie_payload(youtube_cookies_ciphertext)
    unless plaintext.present?
      yield nil
      return
    end

    Dir.mktmpdir("yt-cookies-", Dir.tmpdir) do |dir|
      path = File.join(dir, "cookies.txt")
      File.binwrite(path, plaintext)
      File.chmod(0o600, path)
      yield path
    end
  end

  private

  def normalize_netscape_cookies(raw)
    s = raw.to_s.gsub("\r\n", "\n").strip
    return if s.blank?

    return unless s.match?(/youtube\.com/i)

    s
  end

  def encrypt_cookie_payload(plaintext)
    cookies_encryptor.encrypt_and_sign(plaintext)
  end

  def decrypt_cookie_payload(ciphertext)
    cookies_encryptor.decrypt_and_verify(ciphertext)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage, ArgumentError
    nil
  end

  def cookies_encryptor
    key = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key(COOKIES_KEY_CONTEXT, 32)
    ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-gcm")
  end
end
