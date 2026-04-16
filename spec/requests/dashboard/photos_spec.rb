# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Photos", type: :request do
  let(:author) { create(:user, :author) }
  let(:photo) { create(:photo, author: author) }

  before { sign_in author }

  describe "GET /dashboard/photos" do
    it "renders the index" do
      photo
      get dashboard_photos_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard/photos/:id/edit" do
    it "renders the edit form" do
      get edit_dashboard_photo_path(photo)
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /dashboard/photos/:id" do
    it "discards the photo" do
      photo
      delete dashboard_photo_path(photo)
      expect(response).to redirect_to(dashboard_photos_path)
      expect(photo.reload.discarded?).to be true
    end
  end
end
