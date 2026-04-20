# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pravda::HttpClient do
  let(:base_url) { "https://blogs.pravda.com.ua" }
  let(:client)   { described_class.new(base_url: base_url, sleep_between: 0, max_retries: 1, retry_base_delay: 0, logger: nil) }

  # The client lazily memoizes a Faraday::Connection. We swap the connection
  # out with our own Faraday::Test stack so we never make real network calls.
  def stub_connection(stubs)
    conn = Faraday.new do |c|
      c.adapter(:test, stubs)
    end
    client.instance_variable_set(:@connection, conn)
    conn
  end

  describe "#get_html" do
    # Faraday's test adapter freezes the body strings we hand it, but
    # `transcode_body` calls `force_encoding` (mutating). We hand it a
    # `+""` mutable copy so we exercise the real production path.
    it "returns a transcoded UTF-8 body when the response is HTML" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogs.pravda.com.ua/authors/foo/") { [ 200, { "Content-Type" => "text/html; charset=utf-8" }, +"<html>привіт</html>" ] }
      end
      stub_connection(stubs)

      body = client.get_html("/authors/foo/")
      expect(body).to include("привіт")
      expect(body.encoding).to eq(Encoding::UTF_8)
    end

    it "accepts an absolute URL too" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogs.pravda.com.ua/x") { [ 200, { "Content-Type" => "text/html" }, +"<p>ok</p>" ] }
      end
      stub_connection(stubs)
      expect(client.get_html("https://blogs.pravda.com.ua/x")).to eq("<p>ok</p>")
    end

    it "raises NotFound on HTTP 404" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogs.pravda.com.ua/missing") { [ 404, {}, "" ] }
      end
      stub_connection(stubs)
      expect { client.get_html("/missing") }.to raise_error(Pravda::HttpClient::NotFound)
    end

    it "wraps repeated 503s into Pravda::HttpClient::Error" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogs.pravda.com.ua/boom") { [ 503, {}, "" ] }
      end
      stub_connection(stubs)
      expect { client.get_html("/boom") }.to raise_error(Pravda::HttpClient::Error, /Giving up/)
    end

    it "treats the 'you look like a bot' page as a rate-limit and eventually raises" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogs.pravda.com.ua/bot") { [ 200, { "Content-Type" => "text/html" }, +"you look like a bot, please go away" ] }
      end
      stub_connection(stubs)
      expect { client.get_html("/bot") }.to raise_error(Pravda::HttpClient::Error, /Giving up/)
    end
  end

  describe "#get_binary" do
    it "returns raw bytes on success" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogimg.pravda.com/x.jpg") { [ 200, { "Content-Type" => "image/jpeg" }, "\xFF\xD8binary".b ] }
      end
      stub_connection(stubs)
      expect(client.get_binary("https://blogimg.pravda.com/x.jpg")).to start_with("\xFF\xD8".b)
    end

    it "returns nil on 404" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogimg.pravda.com/missing.jpg") { [ 404, {}, "" ] }
      end
      stub_connection(stubs)
      expect(client.get_binary("https://blogimg.pravda.com/missing.jpg")).to be_nil
    end

    it "raises Error on other non-success statuses" do
      stubs = Faraday::Adapter::Test::Stubs.new do |s|
        s.get("https://blogimg.pravda.com/oops.jpg") { [ 500, {}, "" ] }
      end
      stub_connection(stubs)
      expect { client.get_binary("https://blogimg.pravda.com/oops.jpg") }.to raise_error(Pravda::HttpClient::Error, /HTTP 500/)
    end
  end
end
