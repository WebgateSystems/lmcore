# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Posts", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:category) { create(:category, user: admin_user) }
  let(:post_record) { create(:post, author: admin_user, category: category) }

  describe "GET /admin/posts" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_posts_path
        expect(response).to have_http_status(:success)
      end

      it "displays posts list" do
        post_record
        get admin_posts_path
        expect(response.body).to include("Posts")
      end

      it "filters by status" do
        published_post = create(:post, author: admin_user, status: "published")
        draft_post = create(:post, author: admin_user, status: "draft")

        get admin_posts_path(status: "published")
        expect(response).to have_http_status(:success)
      end

      it "searches by title" do
        post1 = create(:post, author: admin_user, title_i18n: { "en" => "First Post" })
        post2 = create(:post, author: admin_user, title_i18n: { "en" => "Second Post" })

        get admin_posts_path(q: "First")
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_posts_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_posts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/posts/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_post_path(post_record)
        expect(response).to have_http_status(:success)
      end

      it "displays post details" do
        get admin_post_path(post_record)
        expect(response.body).to include(post_record.title)
      end
    end
  end

  describe "GET /admin/posts/new" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get new_admin_post_path
        expect(response).to have_http_status(:success)
      end

      it "displays new post form" do
        get new_admin_post_path
        expect(response.body).to include("New Post")
      end
    end
  end

  describe "POST /admin/posts" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:valid_params) do
        {
          post: {
            title_i18n: { "en" => "Test Post Title", "pl" => "Testowy tytuł posta" },
            content_i18n: { "en" => "Test content", "pl" => "Testowa treść" },
            status: "draft",
            category_id: category.id
          }
        }
      end

      it "creates a new post" do
        expect {
          post admin_posts_path, params: valid_params
        }.to change(Post, :count).by(1)
      end

      it "redirects to the created post" do
        post admin_posts_path, params: valid_params
        expect(response).to redirect_to(admin_post_path(Post.last))
      end

      it "sets the current user as author" do
        post admin_posts_path, params: valid_params
        expect(Post.last.author).to eq(admin_user)
      end

      context "with invalid params" do
        let(:invalid_params) do
          {
            post: {
              title_i18n: {},
              status: "invalid_status"
            }
          }
        end

        it "does not create a post" do
          expect {
            post admin_posts_path, params: invalid_params
          }.not_to change(Post, :count)
        end

        it "renders new template" do
          post admin_posts_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "GET /admin/posts/:id/edit" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get edit_admin_post_path(post_record)
        expect(response).to have_http_status(:success)
      end

      it "displays edit form" do
        get edit_admin_post_path(post_record)
        expect(response.body).to include("Edit Post")
      end
    end
  end

  describe "PATCH /admin/posts/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:update_params) do
        {
          post: {
            title_i18n: { "en" => "Updated Title" }
          }
        }
      end

      it "updates the post" do
        patch admin_post_path(post_record), params: update_params
        post_record.reload
        expect(post_record.title_i18n["en"]).to eq("Updated Title")
      end

      it "redirects to the post" do
        patch admin_post_path(post_record), params: update_params
        expect(response).to redirect_to(admin_post_path(post_record))
      end
    end
  end

  describe "DELETE /admin/posts/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "deletes the post" do
        post_record # ensure it exists
        expect {
          delete admin_post_path(post_record)
        }.to change(Post, :count).by(-1)
      end

      it "redirects to posts list" do
        delete admin_post_path(post_record)
        expect(response).to redirect_to(admin_posts_path)
      end
    end
  end

  describe "POST /admin/posts/:id/publish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:draft_post) { create(:post, author: admin_user, status: "draft") }

      it "publishes the post" do
        post publish_admin_post_path(draft_post)
        draft_post.reload
        expect(draft_post.status).to eq("published")
      end

      it "redirects to the post" do
        post publish_admin_post_path(draft_post)
        expect(response).to redirect_to(admin_post_path(draft_post))
      end
    end
  end

  describe "POST /admin/posts/:id/unpublish" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:published_post) { create(:post, author: admin_user, status: "published") }

      it "unpublishes the post" do
        post unpublish_admin_post_path(published_post)
        published_post.reload
        expect(published_post.status).to eq("draft")
      end
    end
  end

  describe "POST /admin/posts/:id/feature" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "toggles featured status" do
        expect(post_record.featured).to be false
        post feature_admin_post_path(post_record)
        post_record.reload
        expect(post_record.featured).to be true
      end
    end
  end
end
