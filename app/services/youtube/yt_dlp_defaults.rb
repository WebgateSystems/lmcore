# frozen_string_literal: true

module Youtube
  module YtDlpDefaults
    # Even with --skip-download, yt-dlp resolves formats; some videos lack the default
    # merged format and fail with "Requested format is not available".
    # See: https://github.com/yt-dlp/yt-dlp#format-selection
    FORMAT_SELECTOR = "bv*+ba/b/ba/b/worst"
  end
end
