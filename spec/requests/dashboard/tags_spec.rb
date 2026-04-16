# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Tags", type: :request do
  let(:author) { create(:user, :author) }
  let(:tag) { create(:tag) }

  before { sign_in author }

  describe "GET /dashboard/tags" do
    it "renders the index" do
      tag
      get dashboard_tags_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/tags" do
    it "creates a new tag" do
      expect {
        post dashboard_tags_path, params: { tag: { name: "uniquetag", slug: "uniquetag" } }
      }.to change(Tag, :count).by(1)
      expect(response).to redirect_to(dashboard_tags_path)
    end
  end

  describe "PATCH /dashboard/tags/:id" do
    it "updates the tag" do
      patch dashboard_tag_path(tag), params: { tag: { name: "renamedtag" } }
      expect(response).to redirect_to(dashboard_tags_path)
      expect(tag.reload.name).to eq("renamedtag")
    end
  end

  describe "DELETE /dashboard/tags/:id" do
    it "destroys the tag when the actor is a moderator" do
      moderator = create(:user, :moderator)
      sign_out author
      sign_in moderator
      tag
      expect { delete dashboard_tag_path(tag) }.to change(Tag, :count).by(-1)
    end
  end
end
