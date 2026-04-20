# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::BaseController", type: :request do
  describe "GET /dashboard (access guard)" do
    it "redirects regular users with an alert" do
      regular = create(:user)
      sign_in regular
      get dashboard_root_path
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects unauthenticated visitors to sign-in" do
      get dashboard_root_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /dashboard/locale/:interface_locale" do
    let(:author) { create(:user, :author) }
    before { sign_in author }

    it "stores the chosen locale in session+cookie when it's available" do
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return(%w[en pl])

      get dashboard_switch_locale_path(interface_locale: "pl"),
        headers: { "HTTP_REFERER" => dashboard_posts_path }

      expect(session[:locale]).to eq("pl")
      expect(response.cookies["locale"]).to eq("pl")
      expect(response).to have_http_status(:redirect)
    end

    it "ignores unsupported locales but still redirects" do
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return(%w[en])

      get dashboard_switch_locale_path(interface_locale: "xx"),
        headers: { "HTTP_REFERER" => dashboard_posts_path }

      expect(session[:locale]).to be_nil
      expect(response).to have_http_status(:redirect)
    end

    it "strips locale/interface_locale from the referrer URL on the redirect" do
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return(%w[en pl])

      get dashboard_switch_locale_path(interface_locale: "pl"),
        headers: { "HTTP_REFERER" => "#{dashboard_posts_path}?locale=en&page=2" }

      expect(response.location).to include("/dashboard/posts")
      expect(response.location).to include("page=2")
      expect(response.location).not_to include("locale=en")
    end

    it "falls back to the dashboard root when the referrer is unrelated" do
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return(%w[en pl])

      get dashboard_switch_locale_path(interface_locale: "pl"),
        headers: { "HTTP_REFERER" => "https://other-host.test/somewhere/else" }

      # Path component should be `/dashboard`, NOT the foreign referrer path.
      # `response.location` is a full URL using Rails' default test host
      # (`www.example.com`), so we assert on the path, not on whether the
      # string contains "example.com".
      location_path = URI.parse(response.location).path
      expect(location_path).to eq("/dashboard")
      expect(response.location).not_to include("other-host.test")
      expect(response.location).not_to include("/somewhere/else")
    end

    it "falls back to the dashboard root with no referrer at all" do
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return(%w[en pl])

      get dashboard_switch_locale_path(interface_locale: "pl")
      expect(response).to have_http_status(:redirect)
    end
  end
end
