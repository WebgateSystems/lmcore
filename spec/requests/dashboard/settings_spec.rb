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
  end
end
