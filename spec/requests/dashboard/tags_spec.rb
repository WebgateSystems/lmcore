# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Tags", type: :request do
  let(:author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:tag) { create(:tag) }

  before { sign_in author }

  describe "GET /dashboard/tags" do
    it "renders the index showing only tags used on the user's content" do
      mine = create(:post, author: author)
      Tagging.create!(tag: tag, taggable: mine)
      foreign = create(:tag)
      Tagging.create!(tag: foreign, taggable: create(:post))

      get dashboard_tags_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(tag.name)
      expect(response.body).not_to include(foreign.name)
    end
  end

  describe "POST /dashboard/tags" do
    it "creates a new tag (tags are a global vocabulary, but creation is allowed)" do
      expect {
        post dashboard_tags_path, params: { tag: { name: "uniquetag", slug: "uniquetag" } }
      }.to change(Tag, :count).by(1)
      expect(response).to redirect_to(dashboard_tags_path)
    end
  end

  # Editing/deleting global tags is intentionally NOT exposed under /dashboard
  # for any role. Use /admin to manage the platform-wide tag dictionary.
  describe "PATCH /dashboard/tags/:id" do
    it "is forbidden for authors" do
      original = tag.name
      patch dashboard_tag_path(tag), params: { tag: { name: "renamedtag" } }
      expect(flash[:alert]).to be_present
      expect(tag.reload.name).to eq(original)
    end

    it "is forbidden for moderators on /dashboard too" do
      sign_out author
      sign_in moderator
      original = tag.name
      patch dashboard_tag_path(tag), params: { tag: { name: "renamedtag" } }
      expect(flash[:alert]).to be_present
      expect(tag.reload.name).to eq(original)
    end
  end

  describe "DELETE /dashboard/tags/:id" do
    it "is forbidden for moderators on /dashboard" do
      sign_out author
      sign_in moderator
      tag
      delete dashboard_tag_path(tag)
      expect(flash[:alert]).to be_present
      expect(Tag.exists?(tag.id)).to be true
    end
  end
end
