# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Categories", type: :request do
  let(:author) { create(:user, :author) }
  let(:category) { create(:category, user: author) }

  before { sign_in author }

  describe "GET /dashboard/categories" do
    it "renders the index" do
      category
      get dashboard_categories_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard/categories/new" do
    it "renders the new form" do
      get new_dashboard_category_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/categories" do
    it "creates a category owned by the user" do
      expect {
        post dashboard_categories_path, params: { category: { name: "My category", category_type: "general" } }
      }.to change { Category.where(user: author).count }.by(1)
      expect(response).to redirect_to(dashboard_categories_path)
    end
  end

  describe "PATCH /dashboard/categories/:id" do
    it "updates the category" do
      patch dashboard_category_path(category), params: { category: { name: "Updated" } }
      expect(response).to redirect_to(dashboard_categories_path)
    end
  end

  describe "DELETE /dashboard/categories/:id" do
    it "destroys the category" do
      category
      expect { delete dashboard_category_path(category) }.to change(Category, :count).by(-1)
      expect(response).to redirect_to(dashboard_categories_path)
    end
  end

  context "when another user owns the category" do
    let(:other_author) { create(:user, :author) }
    let(:foreign) { create(:category, user: other_author) }

    it "returns 404 when editing" do
      get edit_dashboard_category_path(foreign)
      expect(response).to have_http_status(:not_found)
    end
  end
end
