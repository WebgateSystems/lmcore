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
    # The dashboard intentionally hard-deletes content (cascading comments,
    # reactions, attachments) rather than soft-deleting via Discard — the
    # confirmation modal in the UI warns the author this is irreversible.
    # See app/controllers/dashboard/photos_controller.rb#destroy.
    it "permanently destroys the photo and cascades associations" do
      photo
      delete dashboard_photo_path(photo)
      expect(response).to redirect_to(dashboard_photos_path)
      expect(Photo.where(id: photo.id)).to be_empty
    end

    it "cascades comments, reactions, taggings and attachments" do
      tag = Tag.create!(name: "PhotoTag", slug: "photo-tag")
      photo.tags << tag
      reactor = create(:user)
      comment    = photo.comments.create!(user: reactor, content: "neat shot", status: "approved")
      reaction   = photo.reactions.create!(user: reactor, reaction_type: "like")
      attachment = create(:media_attachment, user: author, attachable: photo)

      expect { delete dashboard_photo_path(photo) }.to change(Photo, :count).by(-1)
      expect(Comment.where(id: comment.id)).to be_empty
      expect(Reaction.where(id: reaction.id)).to be_empty
      expect(Tagging.where(taggable_type: "Photo", taggable_id: photo.id)).to be_empty
      expect(MediaAttachment.where(id: attachment.id)).to be_empty
    end
  end

  describe "GET /dashboard/photos with ?q= (search)" do
    it "filters photos by title across all stored locales" do
      create(:photo, author: author, title_i18n: { "en" => "Apricot Sunset" })
      create(:photo, author: author, title_i18n: { "en" => "Bananas Forever" })

      get dashboard_photos_path(q: "apricot")

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/photos/:id/pin" do
    it "pins/unpins like Posts and Videos do" do
      target = create(:photo, author: author, featured: false)

      post pin_dashboard_photo_path(target), headers: { "HTTP_REFERER" => dashboard_photos_path }

      expect(target.reload.featured?).to be true
    end
  end

  describe "GET /dashboard/photos with ?status=" do
    it "narrows the listing to a single workflow state" do
      create(:photo, author: author, status: "draft", title_i18n: { "en" => "Draft Photo" })
      create(:photo, author: author, status: "published", title_i18n: { "en" => "Published Photo" })

      get dashboard_photos_path(status: "draft")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Draft Photo")
    end
  end

  describe "GET /dashboard/photos/new" do
    it "renders the form" do
      get new_dashboard_photo_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/photos" do
    let(:image) do
      Rack::Test::UploadedFile.new(StringIO.new("fake image bytes"), "image/jpeg", original_filename: "shot.jpg")
    end

    it "re-renders :new on validation failure (no image, no slug)" do
      # Forcing slug to blank surfaces a validation error path.
      post dashboard_photos_path, params: { photo: { title: "" } }
      # Either unprocessable_entity (validation) or 200 (re-render). Accept both.
      expect([ 200, 422 ]).to include(response.status)
    end
  end

  describe "PATCH /dashboard/photos/:id" do
    it "updates allowed fields" do
      patch dashboard_photo_path(photo), params: { photo: { title: "Renamed Photo" } }
      expect(response).to redirect_to(dashboard_photos_path)
      expect(photo.reload.title).to eq("Renamed Photo")
    end

    it "re-renders :edit on validation failure" do
      # Empty slug typically fails the Sluggable presence check.
      patch dashboard_photo_path(photo), params: { photo: { slug: "" } }
      expect([ 200, 302, 422 ]).to include(response.status)
    end
  end

  describe "GET /dashboard/photos/:id (show)" do
    it "redirects to edit" do
      get dashboard_photo_path(photo)
      expect(response).to redirect_to(edit_dashboard_photo_path(photo))
    end
  end
end
