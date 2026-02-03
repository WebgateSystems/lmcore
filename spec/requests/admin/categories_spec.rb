# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Categories", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:category) { create(:category, user: admin_user) }

  describe "GET /admin/categories" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_categories_path
        expect(response).to have_http_status(:success)
      end

      it "displays categories list" do
        category
        get admin_categories_path
        expect(response.body).to include("Categories")
      end

      it "searches by name" do
        create(:category, user: admin_user, name_i18n: { "en" => "Technology" })
        get admin_categories_path(q: "Tech")
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_categories_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_categories_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/categories/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_category_path(category)
        expect(response).to have_http_status(:success)
      end

      it "displays category details" do
        get admin_category_path(category)
        expect(response.body).to include(category.name)
      end
    end
  end

  describe "GET /admin/categories/new" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get new_admin_category_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/categories" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:valid_params) do
        {
          category: {
            name_i18n: { "en" => "New Category", "pl" => "Nowa Kategoria" },
            description_i18n: { "en" => "Category description" },
            category_type: "general",
            slug: "new-category"
          }
        }
      end

      it "creates a new category" do
        expect {
          post admin_categories_path, params: valid_params
        }.to change(Category, :count).by(1)
      end

      it "redirects to the created category" do
        post admin_categories_path, params: valid_params
        expect(response).to redirect_to(admin_category_path(Category.last))
      end

      it "sets the current user as owner" do
        post admin_categories_path, params: valid_params
        expect(Category.last.user).to eq(admin_user)
      end
    end
  end

  describe "GET /admin/categories/:id/edit" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get edit_admin_category_path(category)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/categories/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:update_params) do
        {
          category: {
            name_i18n: { "en" => "Updated Category" }
          }
        }
      end

      it "updates the category" do
        patch admin_category_path(category), params: update_params
        category.reload
        expect(category.name_i18n["en"]).to eq("Updated Category")
      end

      it "redirects to the category" do
        patch admin_category_path(category), params: update_params
        expect(response).to redirect_to(admin_category_path(category))
      end
    end
  end

  describe "DELETE /admin/categories/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "deletes the category" do
        category
        expect {
          delete admin_category_path(category)
        }.to change(Category, :count).by(-1)
      end

      it "redirects to categories list" do
        delete admin_category_path(category)
        expect(response).to redirect_to(admin_categories_path)
      end
    end
  end

  describe "parent category relationship" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:parent_category) { create(:category, user: admin_user, name_i18n: { "en" => "Parent" }) }

      it "creates a child category" do
        child_params = {
          category: {
            name_i18n: { "en" => "Child Category" },
            category_type: "general",
            parent_id: parent_category.id
          }
        }

        expect {
          post admin_categories_path, params: child_params
        }.to change(Category, :count).by(1)

        expect(Category.last.parent).to eq(parent_category)
      end
    end
  end
end
