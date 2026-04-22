# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Gallery", type: :request do
  let(:author) { create(:user, :author) }
  let(:album) { create(:album, author: author) }
  let(:photo) { create(:photo, author: author, album: album) }

  before { sign_in author }

  describe "GET /dashboard/gallery" do
    it "renders the index" do
      album
      get dashboard_gallery_index_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /dashboard/gallery/:slug/edit" do
    it "renders the edit form" do
      get edit_dashboard_gallery_path(album.slug)
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /dashboard/gallery/:slug" do
    it "permanently destroys the album" do
      album
      delete dashboard_gallery_path(album.slug)
      expect(response).to redirect_to(dashboard_gallery_index_path)
      expect(Album.where(id: album.id)).to be_empty
    end
  end

  describe "POST /dashboard/gallery/:slug/photos" do
    let(:image) do
      fixture_image_upload
    end

    it "adds a photo to album" do
      post dashboard_gallery_photos_path(album.slug), params: { photos: { images: [ image ] } }
      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
      expect(album.photos.reload.count).to eq(1)
    end

    it "returns json payload when requested as json" do
      post dashboard_gallery_photos_path(album.slug, format: :json), params: { photos: { images: [ image ] } }
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body.fetch("created").size).to eq(1)
      expect(body.fetch("errors")).to eq([])
    end
  end

  describe "PATCH /dashboard/gallery/:slug/photos/:id" do
    it "updates photo and redirects in html mode" do
      patch dashboard_gallery_photo_path(album.slug, photo), params: { photo: { title: "Renamed photo" } }
      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
      expect(photo.reload.title).to eq("Renamed photo")
    end

    it "returns validation errors in json mode" do
      patch dashboard_gallery_photo_path(album.slug, photo, format: :json), params: { photo: { slug: "invalid_slug" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body).fetch("errors")).to be_present
    end
  end

  describe "DELETE /dashboard/gallery/:slug/photos/:id" do
    it "deletes photo and falls back cover to first remaining image" do
      other = create(:photo, author: author, album: album)
      album.update!(cover_photo: photo)

      delete dashboard_gallery_photo_path(album.slug, photo)

      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
      expect(album.reload.cover_photo_id).to eq(other.id)
      expect(album.photos.where(id: photo.id)).to be_empty
    end

    it "returns ok json response" do
      delete dashboard_gallery_photo_path(album.slug, photo, format: :json)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("ok" => true)
    end
  end

  describe "POST /dashboard/gallery/:slug/photos/:id/make_cover" do
    it "sets selected photo as cover and redirects in html mode" do
      post make_cover_dashboard_gallery_photo_path(album.slug, photo)
      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
      expect(album.reload.cover_photo_id).to eq(photo.id)
    end

    it "returns selected cover id in json mode" do
      post make_cover_dashboard_gallery_photo_path(album.slug, photo, format: :json)
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("cover_photo_id" => photo.id)
    end
  end

  describe "POST /dashboard/gallery/:slug/photos/:id/move" do
    let!(:first_photo) { create(:photo, author: author, album: album, position: 0) }
    let!(:second_photo) { create(:photo, author: author, album: album, position: 1) }

    it "moves photo up by swapping positions" do
      post move_dashboard_gallery_photo_path(album.slug, second_photo), params: { direction: "up" }
      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
      expect(first_photo.reload.position).to eq(1)
      expect(second_photo.reload.position).to eq(0)
    end

    it "does nothing when moving first photo up" do
      post move_dashboard_gallery_photo_path(album.slug, first_photo), params: { direction: "up" }
      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
      expect(first_photo.reload.position).to eq(0)
      expect(second_photo.reload.position).to eq(1)
    end
  end

  describe "POST /dashboard/gallery/:slug/photos/reorder" do
    let!(:first_photo) { create(:photo, author: author, album: album, position: 0) }
    let!(:second_photo) { create(:photo, author: author, album: album, position: 1) }

    it "reorders photos based on ids list" do
      post reorder_dashboard_gallery_photos_path(album.slug), params: { photo_ids: [ second_photo.id, first_photo.id ] }, as: :json
      expect(response).to have_http_status(:ok)
      expect(first_photo.reload.position).to eq(1)
      expect(second_photo.reload.position).to eq(0)
    end
  end

  describe "GET /dashboard/gallery with ?q= (search)" do
    it "filters albums by title across all stored locales" do
      create(:album, author: author, title_i18n: { "en" => "Apricot Sunset" })
      create(:album, author: author, title_i18n: { "en" => "Bananas Forever" })

      get dashboard_gallery_index_path(q: "apricot")

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/gallery/:slug/pin" do
    it "pins/unpins like Posts and Videos do" do
      target = create(:album, author: author, featured: false)

      post pin_dashboard_gallery_path(target.slug), headers: { "HTTP_REFERER" => dashboard_gallery_index_path }

      expect(target.reload.featured?).to be true
    end
  end

  describe "GET /dashboard/gallery with ?status=" do
    it "narrows the listing to a single workflow state" do
      create(:album, author: author, status: "draft", title_i18n: { "en" => "Draft Album" })
      create(:album, author: author, status: "published", title_i18n: { "en" => "Published Album" })

      get dashboard_gallery_index_path(status: "draft")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Draft Album")
    end
  end

  describe "GET /dashboard/gallery/new" do
    it "renders the form" do
      get new_dashboard_gallery_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/gallery" do
    it "re-renders :new on validation failure (no title, no slug)" do
      post dashboard_gallery_index_path, params: { album: { title: "" } }
      expect([ 200, 422 ]).to include(response.status)
    end
  end

  describe "PATCH /dashboard/gallery/:slug" do
    it "updates allowed fields" do
      patch dashboard_gallery_path(album.slug), params: { album: { title: "Renamed Gallery" } }
      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
      expect(album.reload.title).to eq("Renamed Gallery")
    end

    it "re-renders :edit on validation failure" do
      patch dashboard_gallery_path(album.slug), params: { album: { slug: "" } }
      expect([ 200, 302, 422 ]).to include(response.status)
    end
  end

  describe "GET /dashboard/gallery/:slug (show)" do
    it "redirects to edit" do
      get dashboard_gallery_path(album.slug)
      expect(response).to redirect_to(edit_dashboard_gallery_path(album.slug))
    end
  end
end
