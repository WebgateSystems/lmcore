# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::BaseController", type: :request do
  describe "GET /dashboard (access guard)" do
    it "allows active regular users into their own dashboard" do
      regular = create(:user)
      sign_in regular

      get dashboard_root_path

      expect(response).to have_http_status(:success)
    end

    it "redirects suspended users with an alert" do
      suspended = create(:user, :suspended)
      sign_in suspended

      get dashboard_root_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects unauthenticated visitors to sign-in" do
      get dashboard_root_path
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "PATCH /dashboard/workspace" do
    it "switches to a blog where the current user has a scoped role" do
      owner = create(:user, username: "owner")
      actor = create(:user, username: "actor")
      role = create(:role, slug: "editor", priority: 40, system_role: true)
      actor.assign_role!(role, scope: owner, granted_by: owner)
      create(:post, author: owner, title_i18n: { "en" => "Owner workspace post" })
      create(:post, author: actor, title_i18n: { "en" => "Actor workspace post" })

      sign_in actor

      patch dashboard_workspace_path, params: { blog_user_id: owner.id }

      expect(response).to have_http_status(:redirect)
      get dashboard_posts_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Owner workspace post")
      expect(response.body).not_to include("Actor workspace post")
    end

    it "does not switch to a blog without a scoped role" do
      owner = create(:user, username: "owner")
      actor = create(:user, username: "actor")
      create(:post, author: owner, title_i18n: { "en" => "Inaccessible workspace post" })
      create(:post, author: actor, title_i18n: { "en" => "Own workspace post" })

      sign_in actor

      patch dashboard_workspace_path, params: { blog_user_id: owner.id }

      expect(response).to have_http_status(:redirect)
      get dashboard_posts_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Own workspace post")
      expect(response.body).not_to include("Inaccessible workspace post")
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
