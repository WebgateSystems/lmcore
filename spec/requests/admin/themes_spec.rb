# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Themes", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let!(:theme) { create(:theme, name: "Default", slug: "default", path: "default", status: "default", is_system: true) }

  describe "GET /admin/themes" do
    it "returns success for admins" do
      sign_in admin_user

      get admin_themes_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Themes")
      expect(response.body).to include("Default")
    end

    it "redirects regular users" do
      sign_in regular_user

      get admin_themes_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /admin/themes" do
    before { sign_in admin_user }

    it "creates a theme record pointing at an existing folder" do
      post admin_themes_path, params: {
        theme: {
          name: "Editorial",
          slug: "editorial",
          path: "default",
          status: "active",
          version: "1.0.0",
          author: "LibreMedia",
          is_system: "1",
          is_premium: "0",
          price_cents: "0"
        }
      }

      expect(response).to redirect_to(admin_theme_path(Theme.find_by!(slug: "editorial")))
    end

    it "stores exclusive user access" do
      owner = create(:user, username: "am")

      post admin_themes_path, params: {
        theme: {
          name: "AM",
          slug: "am",
          path: "am",
          status: "active",
          version: "1.0.0",
          exclusive_user_ids: [ owner.id ]
        }
      }

      created = Theme.find_by!(slug: "am")
      expect(created.exclusive_users).to contain_exactly(owner)
    end

    it "keeps only one default theme" do
      post admin_themes_path, params: {
        theme: {
          name: "New Default",
          slug: "new-default",
          path: "default",
          status: "default",
          version: "1.0.0"
        }
      }

      created = Theme.find_by!(slug: "new-default")
      expect(created.reload.status).to eq("default")
      expect(theme.reload.status).to eq("active")
    end
  end

  describe "PATCH /admin/themes/:id" do
    before { sign_in admin_user }

    it "updates theme metadata and exclusive access" do
      owner = create(:user, username: "am")

      patch admin_theme_path(theme), params: {
        theme: {
          name: "Default Updated",
          slug: theme.slug,
          path: "default",
          status: "default",
          version: "1.0.1",
          exclusive_user_ids: [ owner.id ]
        }
      }

      expect(response).to redirect_to(admin_theme_path(theme))
      expect(theme.reload.name).to eq("Default Updated")
      expect(theme.exclusive_users).to contain_exactly(owner)
    end
  end
end
