# frozen_string_literal: true

require "rails_helper"

RSpec.describe Assistant::PostTranslationClient do
  subject(:client) { described_class.new(base_url: "http://assistant.test", token: "secret") }

  describe "#call" do
    it "posts translation payload to the assistant service" do
      request = Struct.new(:headers, :body).new({}, nil)
      response = instance_double(Faraday::Response,
        success?: true,
        body: { data: { translations: { en: { title: "Hello" } } } }.to_json)
      allow(Faraday).to receive(:post).and_yield(request).and_return(response)

      result = client.call(
        source_locale: "pl",
        target_locales: %w[en],
        content_format: "markdown",
        content: { title: "Cześć" },
        metadata: { post_id: 1 }
      )

      expect(Faraday).to have_received(:post).with("http://assistant.test/api/v1/assistant/translations")
      expect(request.headers["Authorization"]).to eq("Bearer secret")
      expect(JSON.parse(request.body).dig("translation", "target_locales")).to eq([ "en" ])
      expect(result.dig("translations", "en", "title")).to eq("Hello")
    end

    it "raises a readable error when token is missing" do
      missing_token_client = described_class.new(base_url: "http://assistant.test", token: nil)

      expect do
        missing_token_client.call(
          source_locale: "pl",
          target_locales: %w[en],
          content_format: "markdown",
          content: { title: "Cześć" }
        )
      end.to raise_error(described_class::Error, /LM_ASSISTANT_TOKEN/)
    end

    it "raises a readable error for non-success responses" do
      response = instance_double(Faraday::Response, success?: false, body: { errors: [ "not authorized" ] }.to_json)
      allow(Faraday).to receive(:post).and_return(response)

      expect do
        client.call(
          source_locale: "pl",
          target_locales: %w[en],
          content_format: "markdown",
          content: { title: "Cześć" }
        )
      end.to raise_error(described_class::Error, /not authorized/)
    end
  end
end
