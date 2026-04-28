# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sso::ClientApplication do
  before do
    Doorkeeper::Application.where(uid: Settings.sso.client_uid).delete_all
  end

  describe ".ensure_for_redirect!" do
    it "creates the client application with configured credentials" do
      app = described_class.ensure_for_redirect!("https://app.example/sso/callback")

      expect(app.uid).to eq(Settings.sso.client_uid)
      expect(app.name).to eq(Settings.sso.client_name)
      expect(app.secret).to eq(Settings.sso.client_secret)
      expect(app.confidential).to be(true)
      expect(app.scopes).to include("openid")
      expect(app.redirect_uri).to include("https://app.example/sso/callback")
    end

    it "merges redirect URIs without duplicates" do
      described_class.ensure_for_redirect!("https://app.example/sso/callback")
      app = described_class.ensure_for_redirect!("https://app.example/sso/callback")
      described_class.ensure_for_redirect!("https://app.example/sso/other")

      app.reload
      lines = app.redirect_uri.split(/\s+/).reject(&:blank?)

      expect(lines).to include("https://app.example/sso/callback", "https://app.example/sso/other")
      expect(lines.count("https://app.example/sso/callback")).to eq(1)
    end
  end
end
