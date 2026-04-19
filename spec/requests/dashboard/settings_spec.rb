# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Settings", type: :request do
  let(:author) { create(:user, :author) }

  before { sign_in author }

  describe "GET /dashboard/settings" do
    it "renders successfully" do
      get dashboard_settings_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /dashboard/settings" do
    it "saves editable settings for the current user" do
      patch dashboard_settings_path, params: {
        settings: { site_name: "My Site", youtube_url: "https://www.youtube.com/@example/videos" }
      }
      expect(response).to redirect_to(dashboard_settings_path)
      expect(SiteSetting.find_by(user: author, key: "youtube_url").typed_value).to eq("https://www.youtube.com/@example/videos")
    end

    it "does not store YouTube cookies without acknowledgement" do
      cookies_body = "# Netscape HTTP Cookie File\n.youtube.com\tTRUE\t/\tTRUE\t9999999999\tconsent\ty"
      patch dashboard_settings_path, params: {
        youtube_integration: { netscape_cookies: cookies_body, age_acknowledged: "0" }
      }

      expect(response).to redirect_to(dashboard_settings_path)
      expect(flash[:alert]).to be_present
      expect(author.reload.youtube_cookies_ciphertext).to be_blank
    end

    it "stores available locales as a JSON array, not Array#to_s" do
      patch dashboard_settings_path, params: {
        settings: { available_locales: %w[en pl uk ru], default_locale: "pl" }
      }
      expect(response).to redirect_to(dashboard_settings_path)

      setting = SiteSetting.find_by(user: author, key: "available_locales")
      expect(setting.value_type).to eq("json")
      expect(setting.typed_value).to match_array(%w[en pl uk ru])
      expect(SiteSetting.blog_available_locale_codes_for(author)).to eq(%w[en pl ru uk])
    end

    it "clamps default_locale into the available locales list" do
      patch dashboard_settings_path, params: {
        settings: { available_locales: %w[en pl], default_locale: "ru" }
      }

      default_setting = SiteSetting.find_by(user: author, key: "default_locale")
      expect(default_setting.typed_value).to eq("en")
    end

    it "does not wipe available_locales when the field is not submitted" do
      patch dashboard_settings_path, params: {
        settings: { available_locales: %w[en pl uk] }
      }
      expect(SiteSetting.blog_available_locale_codes_for(author)).to eq(%w[en pl uk])

      patch dashboard_settings_path, params: { settings: { site_name: "Other" } }
      expect(SiteSetting.blog_available_locale_codes_for(author)).to eq(%w[en pl uk])
    end
  end

  describe "GET /dashboard/settings (legacy data)" do
    it "recovers from a legacy String#to_s'd Array stored under available_locales" do
      SiteSetting.create!(
        user: author,
        key: "available_locales",
        value: { "data" => '["en", "uk", "ru", "pl"]' },
        value_type: "string",
        category: "general"
      )
      expect(SiteSetting.blog_available_locale_codes_for(author)).to eq(%w[en pl ru uk])
    end
  end
end
