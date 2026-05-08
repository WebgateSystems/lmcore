# frozen_string_literal: true

require "json"

module Assistant
  class PostTranslationClient
    Error = Class.new(StandardError)

    ENDPOINT = "/api/v1/assistant/translations"

    def initialize(base_url: Settings.services.assistant.endpoint,
                   token: Settings.services.assistant.token,
                   read_timeout: Settings.services.assistant.read_timeout)
      @base_url = base_url.to_s.delete_suffix("/")
      @token = token.to_s.strip
      @read_timeout = read_timeout.to_i
    end

    def call(source_locale:, target_locales:, content:, content_format:, metadata: {})
      raise Error, "LM_ASSISTANT_TOKEN is not configured" if @token.blank?

      response = Faraday.post("#{@base_url}#{ENDPOINT}") do |request|
        request.headers["Accept"] = "application/json"
        request.headers["Content-Type"] = "application/json"
        request.headers["Authorization"] = "Bearer #{@token}"
        request.options.timeout = @read_timeout if @read_timeout.positive? && request.respond_to?(:options)
        request.body = request_body(
          source_locale: source_locale,
          target_locales: target_locales,
          content: content,
          content_format: content_format,
          metadata: metadata
        ).to_json
      end

      parse_response(response)
    rescue Faraday::Error => e
      raise Error, e.message
    end

    private

    def request_body(source_locale:, target_locales:, content:, content_format:, metadata:)
      {
        translation: {
          source_locale: source_locale,
          target_locales: target_locales,
          content_format: content_format.presence || "html",
          content: content,
          metadata: metadata
        }
      }
    end

    def parse_response(response)
      body = JSON.parse(response.body.to_s.presence || "{}")
      return body.fetch("data") if response.success?

      message = body["errors"].presence || body["error"].presence || "Assistant request failed"
      raise Error, Array(message).join(", ")
    rescue JSON::ParserError
      raise Error, "Assistant returned invalid JSON"
    end
  end
end
