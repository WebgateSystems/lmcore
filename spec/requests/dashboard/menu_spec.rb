# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Menu", type: :request do
  let(:author) { create(:user, :author) }

  before { sign_in author }

  describe "GET /dashboard/menu" do
    it "renders menu editor" do
      get dashboard_menu_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /dashboard/menu" do
    let!(:first_page) { create(:page, :published, :in_menu, author: author, slug: "donate", menu_position: 1) }
    let!(:second_page) { create(:page, :published, :in_menu, author: author, slug: "team", menu_position: 2) }

    it "persists order and visibility for static and page items" do
      patch dashboard_menu_path, params: {
        menu: {
          order: [ "home", "page:#{second_page.id}", "about", "videos", "posts", "gallery", "page:#{first_page.id}" ],
          visibility: {
            "home" => "1",
            "about" => "0",
            "videos" => "1",
            "posts" => "1",
            "gallery" => "1",
            "page:#{second_page.id}" => "1",
            "page:#{first_page.id}" => "0"
          }
        }
      }

      expect(response).to redirect_to(dashboard_menu_path)

      stored = SiteSetting.get("navigation_menu", user: author, default: [])
      expect(stored).to be_an(Array)
      expect(stored.first["id"]).to eq("home")
      expect(stored.first["position"]).to eq(1)
      expect(stored.find { |it| it["id"] == "about" }["visible"]).to eq(false)
      expect(stored.find { |it| it["id"] == "page:#{first_page.id}" }["visible"]).to eq(false)
    end
  end
end
