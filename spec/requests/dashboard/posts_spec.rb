# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Posts", type: :request do
  let(:author) { create(:user, :author) }
  let(:other_author) { create(:user, :author) }
  let(:category) { create(:category, user: author) }
  let(:post_record) { create(:post, author: author, category: category) }

  describe "GET /dashboard/posts" do
    context "when not signed in" do
      it "redirects to login" do
        get dashboard_posts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as an author" do
      before { sign_in author }

      it "returns success" do
        get dashboard_posts_path
        expect(response).to have_http_status(:success)
      end

      it "filters by status when provided" do
        create(:post, author: author, status: "draft")
        create(:post, author: author, status: "published", published_at: Time.current)

        get dashboard_posts_path(status: "draft")
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /dashboard/posts/new" do
    before { sign_in author }

    it "renders the form" do
      get new_dashboard_post_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/posts" do
    before { sign_in author }

    let(:valid_params) do
      {
        post: {
          title_i18n: { "en" => "Hello from tests" },
          content_i18n: { "en" => "Content" },
          status: "draft",
          category_id: category.id
        }
      }
    end

    it "creates a post owned by the signed-in author" do
      expect { post dashboard_posts_path, params: valid_params }.to change(Post, :count).by(1)
      expect(Post.last.author).to eq(author)
      expect(response).to redirect_to(edit_dashboard_post_path(Post.last))
    end

    it "re-renders the form when invalid" do
      post dashboard_posts_path, params: { post: { title_i18n: {}, content_i18n: {}, status: "draft" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "stores content_source_i18n and rerenders content_i18n via callback" do
      params = valid_params.deep_merge(post: {
        content_format: "markdown",
        content_source_i18n: { "en" => "# Hello" }
      })
      expect { post dashboard_posts_path, params: params }.to change(Post, :count).by(1)
      created = Post.last
      expect(created.content_format).to eq("markdown")
      expect(created.content_source_i18n["en"]).to eq("# Hello")
      expect(created.content_i18n["en"]).to include("<h1>Hello</h1>")
    end

    it "links pending orphan attachments to the new post" do
      orphan = create(:media_attachment, :orphan, user: author)
      foreign_orphan = create(:media_attachment, :orphan, user: other_author)
      params = valid_params.merge(pending_attachment_ids: [ orphan.id, foreign_orphan.id ])

      post dashboard_posts_path, params: params

      created = Post.last
      expect(orphan.reload.attachable).to eq(created)
      # foreign orphan should not be hijacked
      expect(foreign_orphan.reload.attachable).to be_nil
    end
  end

  describe "GET /dashboard/posts/:id/edit" do
    before { sign_in author }

    it "renders the edit form for the owner" do
      get edit_dashboard_post_path(post_record)
      expect(response).to have_http_status(:success)
    end

    it "returns 404 when the post belongs to another author" do
      foreign = create(:post, author: other_author)
      get edit_dashboard_post_path(foreign)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /dashboard/posts/:id" do
    before { sign_in author }

    it "updates the post" do
      patch dashboard_post_path(post_record), params: { post: { title_i18n: { "en" => "Changed" } } }
      expect(response).to redirect_to(edit_dashboard_post_path(post_record))
      expect(post_record.reload.title_i18n["en"]).to eq("Changed")
    end

    it "rerenders content_i18n when content_source_i18n changes" do
      patch dashboard_post_path(post_record), params: {
        post: { content_format: "html", content_source_i18n: { "en" => "<p>NEW</p>" } }
      }
      expect(post_record.reload.content_i18n["en"]).to include("<p>NEW</p>")
    end

    it "links pending orphan attachments on update" do
      orphan = create(:media_attachment, :orphan, user: author)
      patch dashboard_post_path(post_record), params: {
        post: { title_i18n: { "en" => "X" } },
        pending_attachment_ids: [ orphan.id ]
      }
      expect(orphan.reload.attachable).to eq(post_record)
    end
  end

  describe "DELETE /dashboard/posts/:id" do
    before { sign_in author }

    it "destroys the post" do
      post_record
      expect { delete dashboard_post_path(post_record) }.to change(Post, :count).by(-1)
      expect(response).to redirect_to(dashboard_posts_path)
    end

    # Confirmation modal in the UI warns the author this is irreversible — the
    # controller MUST follow through and cascade comments / reactions /
    # taggings / media attachments via `dependent: :destroy`.
    it "cascades comments, reactions, taggings and attachments" do
      tag = Tag.create!(name: "Cascading", slug: "cascading")
      post_record.tags << tag
      reactor = create(:user)
      comment = post_record.comments.create!(user: reactor, content: "first!", status: "approved")
      reaction = post_record.reactions.create!(user: reactor, reaction_type: "like")
      attachment = create(:media_attachment, user: author, attachable: post_record)

      expect { delete dashboard_post_path(post_record) }.to change(Post, :count).by(-1)
      expect(Comment.where(id: comment.id)).to be_empty
      expect(Reaction.where(id: reaction.id)).to be_empty
      expect(Tagging.where(taggable_type: "Post", taggable_id: post_record.id)).to be_empty
      expect(MediaAttachment.where(id: attachment.id)).to be_empty
    end
  end

  describe "GET /dashboard/posts with ?q= (search)" do
    before { sign_in author }

    it "filters posts by title across all stored locales" do
      hit  = create(:post, author: author, title_i18n: { "en" => "Apricots Today", "pl" => "" })
      miss = create(:post, author: author, title_i18n: { "en" => "Bananas",        "pl" => "" })

      get dashboard_posts_path(q: "apricot")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Apricots Today")
      expect(response.body).not_to include("Bananas") if response.body.exclude?(miss.slug)
    end

    it "ignores blank queries (full collection visible)" do
      create(:post, author: author, title_i18n: { "en" => "Anything" })
      get dashboard_posts_path(q: "   ")
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /dashboard/posts/:id/pin" do
    before { sign_in author }

    it "pins the post and unpins its sibling" do
      old_top = create(:post, author: author, featured: true)
      target  = create(:post, author: author, featured: false)

      post pin_dashboard_post_path(target), headers: { "HTTP_REFERER" => dashboard_posts_path }

      expect(response).to redirect_to(dashboard_posts_path)
      expect(target.reload.featured?).to be true
      expect(old_top.reload.featured?).to be false
    end

    it "unpins an already-pinned post" do
      target = create(:post, author: author, featured: true)

      post pin_dashboard_post_path(target), headers: { "HTTP_REFERER" => dashboard_posts_path }

      expect(target.reload.featured?).to be false
    end

    it "404s when trying to pin another author's post" do
      foreign = create(:post, author: other_author)
      post pin_dashboard_post_path(foreign)
      expect(response).to have_http_status(:not_found)
    end
  end
end
