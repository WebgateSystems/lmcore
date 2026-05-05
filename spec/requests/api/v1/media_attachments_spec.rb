# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::MediaAttachments", type: :request do
  let(:user) { create(:user, :author) }
  let(:other_user) { create(:user, :author) }
  let(:headers) { api_auth_headers(user) }

  let(:upload) { MediaAttachmentFactoryHelpers.rack_test_uploaded_file_for("image") }

  describe "GET /api/v1/media_attachments" do
    it "requires authentication" do
      get "/api/v1/media_attachments", headers: api_json_headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns own attachments scoped by current user" do
      mine    = create(:media_attachment, user: user)
      foreign = create(:media_attachment, user: other_user)

      get "/api/v1/media_attachments", headers: headers

      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body)["attachments"].map { |a| a["id"] }
      expect(ids).to include(mine.id)
      expect(ids).not_to include(foreign.id)
    end

    it "filters by attachment_type" do
      img = create(:media_attachment, user: user, attachment_type: "image")
      doc = create(:media_attachment, :document, user: user)

      get "/api/v1/media_attachments", params: { attachment_type: "image" }, headers: headers
      ids = JSON.parse(response.body)["attachments"].map { |a| a["id"] }
      expect(ids).to include(img.id)
      expect(ids).not_to include(doc.id)
    end

    it "filters by orphan=true" do
      orphan = create(:media_attachment, :orphan, user: user)
      attached_post = create(:post, author: user)
      attached = create(:media_attachment, user: user, attachable: attached_post)

      get "/api/v1/media_attachments", params: { orphan: "true" }, headers: headers
      ids = JSON.parse(response.body)["attachments"].map { |a| a["id"] }
      expect(ids).to include(orphan.id)
      expect(ids).not_to include(attached.id)
    end
  end

  describe "POST /api/v1/media_attachments" do
    it "creates an orphan attachment when no attachable is given" do
      params = { media_attachment: { file: upload, attachment_type: "image",
                                     alt_text_i18n: { en: "x" } } }
      expect {
        post "/api/v1/media_attachments", params: params, headers: headers
      }.to change(MediaAttachment, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)["attachment"]
      expect(json["attachable_id"]).to be_nil
      expect(json["shortcode"]).to start_with("[[fig:")
    end

    it "attaches to a Post owned by the current user" do
      post_record = create(:post, author: user)
      params = { attachable_type: "Post", attachable_id: post_record.id,
                 media_attachment: { file: upload, attachment_type: "image" } }

      post "/api/v1/media_attachments", params: params, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)["attachment"]
      expect(json["attachable_type"]).to eq("Post")
      expect(json["attachable_id"]).to eq(post_record.id)
    end

    it "attaches to a Page owned by the current user" do
      page = create(:page, author: user)
      params = { attachable_type: "Page", attachable_id: page.id,
                 media_attachment: { file: upload, attachment_type: "image" } }

      post "/api/v1/media_attachments", params: params, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)["attachment"]
      expect(json["attachable_type"]).to eq("Page")
      expect(json["attachable_id"]).to eq(page.id)
    end

    it "rejects attaching to a Post owned by someone else" do
      post_record = create(:post, author: other_user)
      params = { attachable_type: "Post", attachable_id: post_record.id,
                 media_attachment: { file: upload, attachment_type: "image" } }

      post "/api/v1/media_attachments", params: params, headers: headers
      expect(response).to have_http_status(:forbidden)
    end

    it "rejects unsupported attachable types" do
      params = { attachable_type: "User", attachable_id: user.id,
                 media_attachment: { file: upload, attachment_type: "image" } }

      post "/api/v1/media_attachments", params: params, headers: headers
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 422 on invalid params" do
      params = { media_attachment: { attachment_type: "image" } }
      post "/api/v1/media_attachments", params: params, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/media_attachments/:id" do
    let(:attachment) { create(:media_attachment, user: user) }

    it "updates metadata for the owner" do
      patch "/api/v1/media_attachments/#{attachment.id}",
            params: { media_attachment: { caption_i18n: { en: "new" }, position: 7 } },
            headers: headers

      expect(response).to have_http_status(:ok)
      attachment.reload
      expect(attachment.caption_i18n["en"]).to eq("new")
      expect(attachment.position).to eq(7)
    end

    it "forbids non-owner" do
      foreign = create(:media_attachment, user: other_user)
      patch "/api/v1/media_attachments/#{foreign.id}",
            params: { media_attachment: { position: 1 } },
            headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/media_attachments/:id" do
    it "destroys an owned attachment" do
      attachment = create(:media_attachment, user: user)
      expect {
        delete "/api/v1/media_attachments/#{attachment.id}", headers: headers
      }.to change(MediaAttachment, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it "forbids destroying someone else's attachment" do
      foreign = create(:media_attachment, user: other_user)
      delete "/api/v1/media_attachments/#{foreign.id}", headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end
end
