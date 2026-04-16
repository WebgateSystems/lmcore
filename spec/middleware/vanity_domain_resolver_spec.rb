# frozen_string_literal: true

require "rails_helper"

RSpec.describe VanityDomainResolver do
  subject(:middleware) { described_class.new(app) }

  let(:app) { ->(env) { [ 200, {}, [ env["PATH_INFO"] ] ] } }

  def call_with(host:, path: "/")
    env = { "HTTP_HOST" => host, "PATH_INFO" => path }
    _status, _headers, body = middleware.call(env)
    { path: env["PATH_INFO"], original_host: env["ORIGINAL_HOST"], body: body.first }
  end

  describe "with the main host" do
    it "leaves path untouched for libremedia.org" do
      result = call_with(host: "libremedia.org", path: "/some/path")
      expect(result[:path]).to eq("/some/path")
      expect(result[:original_host]).to be_nil
    end

    it "leaves path untouched for localhost" do
      result = call_with(host: "localhost", path: "/posts")
      expect(result[:path]).to eq("/posts")
    end

    it "leaves path untouched for IP addresses" do
      result = call_with(host: "192.168.0.1", path: "/posts")
      expect(result[:path]).to eq("/posts")
    end
  end

  describe "with a vanity subdomain" do
    let!(:user) { create(:user, username: "amg", vanity_domain: "amg.libremedia.org", status: "active") }

    it "rewrites root path to the user's blog root" do
      result = call_with(host: "amg.libremedia.org", path: "/")
      expect(result[:path]).to eq("/blogs/amg")
      expect(result[:original_host]).to eq("amg.libremedia.org")
    end

    it "rewrites nested paths by prefixing with /blogs/:slug" do
      result = call_with(host: "amg.libremedia.org", path: "/posts/hello")
      expect(result[:path]).to eq("/blogs/amg/posts/hello")
    end

    it "ignores the port in the Host header" do
      result = call_with(host: "amg.libremedia.org:3000", path: "/videos")
      expect(result[:path]).to eq("/blogs/amg/videos")
    end

    it "does not rewrite when user is suspended" do
      user.update!(status: "suspended")
      result = call_with(host: "amg.libremedia.org", path: "/posts")
      expect(result[:path]).to eq("/posts")
      expect(result[:original_host]).to be_nil
    end

    it "does not rewrite when vanity_domain does not match any user" do
      result = call_with(host: "unknown.libremedia.org", path: "/posts")
      expect(result[:path]).to eq("/posts")
    end
  end
end
