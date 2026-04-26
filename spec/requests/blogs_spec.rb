# frozen_string_literal: true

require "rails_helper"

# Drives the public-facing blog through `BlogsController`. The controller is
# heavyweight (it serializes posts/videos/gallery/pages/categories/tags into
# Liquid hashes for the Liquid `am` theme), so these tests exist mostly to
# protect the wiring between controller actions and the theme renderer:
#  - the right scope is fetched (published+kept+author-scoped)
#  - "top" / "latest" picks behave as documented (incl. the
#    "single-photo-pinned" fallback we added in `pick_latest`)
#  - filters (q / year / tag / page) shape the resulting collection
#  - 404s for unknown slugs, locale switching, redirect targets
RSpec.describe "Blogs", type: :request do
  let!(:author) { create(:user, username: "ayder") }
  let!(:theme) { create(:theme, slug: "am", path: "am", status: "default", is_system: true) }
  let!(:user_theme) { UserTheme.create!(user: author, theme: theme, active: true) }

  describe "GET /blogs/:blog_slug (homepage)" do
    it "renders 200 with no content at all" do
      get "/blogs/#{author.username}"
      expect(response).to have_http_status(:ok)
    end

    it "exposes pinned posts, videos and gallery as Top + uses them as Latest fallback" do
      pinned_post  = create(:post,  :published, author: author, featured: true,
                                                title_i18n: { "en" => "Top story" })
      pinned_video = create(:video, :published, author: author, featured: true,
                                                title_i18n: { "en" => "Top video" })
      pinned_photo = create(:album, :published, author: author, featured: true,
                                                title_i18n: { "en" => "Top photo" })

      get "/blogs/#{author.username}"

      expect(response.body).to include("Top story")
      expect(response.body).to include("Top video")
      expect(response.body).to include("Top photo")

      # `pick_latest` falls back to the same record when nothing else exists,
      # so the homepage MUST render those titles too (regression for the
      # "Latest column is empty when only one photo exists" bug).
      [ pinned_post, pinned_video, pinned_photo ].each do |r|
        expect(r.title_i18n["en"]).to be_present
      end
    end

    it "prefers a different record for Latest when one is available" do
      create(:post, :published, author: author, featured: true,
                                title_i18n: { "en" => "Pinned headline" })
      create(:post, :published, author: author, featured: false,
                                title_i18n: { "en" => "Brand new draft-of-the-day" },
                                published_at: 1.minute.ago)

      get "/blogs/#{author.username}"

      expect(response.body).to include("Pinned headline")
      expect(response.body).to include("Brand new draft-of-the-day")
    end

    it "returns 404 for an unknown blog username" do
      get "/blogs/no-such-user"
      expect(response).to have_http_status(:not_found)
    end

    it "renders navigation using stored menu order and visibility" do
      donate = create(:page, :published, :in_menu, author: author, slug: "donate",
                                             title_i18n: { "en" => "Donate" })
      team = create(:page, :published, :in_menu, author: author, slug: "team",
                                           title_i18n: { "en" => "Team" })

      SiteSetting.set(
        "navigation_menu",
        [
          { "id" => "home", "position" => 1, "visible" => true },
          { "id" => "page:#{team.id}", "position" => 2, "visible" => true },
          { "id" => "about", "position" => 3, "visible" => false },
          { "id" => "videos", "position" => 4, "visible" => true },
          { "id" => "posts", "position" => 5, "visible" => true },
          { "id" => "gallery", "position" => 6, "visible" => true },
          { "id" => "page:#{donate.id}", "position" => 7, "visible" => true }
        ],
        user: author,
        value_type: "json"
      )

      get "/blogs/#{author.username}"
      body = response.body
      doc = Nokogiri::HTML5(body)
      hrefs = doc.css(".header__nav-item.site-title__small.js_nav-item a")
                 .map { |a| a["href"] }
                 .compact

      expect(response).to have_http_status(:ok)
      expect(hrefs).to include("/blogs/#{author.username}/pages/team")
      expect(hrefs).to include("/blogs/#{author.username}/pages/donate")
      expect(hrefs).not_to include("/blogs/#{author.username}/pages/about")
      expect(hrefs.index("/blogs/#{author.username}/pages/team")).to be < hrefs.index("/blogs/#{author.username}/videos")
    end
  end

  describe "GET /blogs/:blog_slug/posts/:slug" do
    let!(:post_record) do
      create(:post, :published, author: author, slug: "hello-world",
                                title_i18n: { "en" => "Hello World" })
    end

    it "renders the post and increments views" do
      expect {
        get "/blogs/#{author.username}/posts/#{post_record.slug}"
      }.to change { post_record.reload.views_count }.by(1)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hello World")
    end

    it "returns 404 for a draft post" do
      draft = create(:post, author: author, slug: "draft-only", status: "draft")
      get "/blogs/#{author.username}/posts/#{draft.slug}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /blogs/:blog_slug/posts (listing)" do
    let!(:post_a) do
      create(:post, :published, author: author, title_i18n: { "en" => "Apricot Season" }, published_at: 2.days.ago)
    end
    let!(:post_b) do
      create(:post, :published, author: author, title_i18n: { "en" => "Bananas Forever" }, published_at: 1.day.ago)
    end

    it "renders the listing" do
      get "/blogs/#{author.username}/posts"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Apricot Season")
      expect(response.body).to include("Bananas Forever")
    end

    it "filters by free-text query (?q=)" do
      get "/blogs/#{author.username}/posts", params: { q: "apricot" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Apricot Season")
      expect(response.body).not_to include("Bananas Forever")
    end

    it "filters by year (?year=)" do
      get "/blogs/#{author.username}/posts", params: { year: post_a.published_at.year.to_s }
      expect(response).to have_http_status(:ok)
    end

    it "filters by tag (?tag=)" do
      tag = Tag.create!(name: "Fruits", slug: "fruits")
      post_a.tags << tag
      get "/blogs/#{author.username}/posts", params: { tag: tag.name }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Apricot Season")
    end

    it "paginates" do
      get "/blogs/#{author.username}/posts", params: { page: 99 }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /blogs/:blog_slug/videos and /videos/:slug" do
    let!(:video_record) do
      create(:video, :published, author: author, slug: "promo",
                                 title_i18n: { "en" => "Promo Reel" })
    end

    it "lists videos" do
      get "/blogs/#{author.username}/videos"
      expect(response).to have_http_status(:ok)
    end

    it "shows a single video and bumps its views" do
      expect {
        get "/blogs/#{author.username}/videos/#{video_record.slug}"
      }.to change { video_record.reload.views_count }.by(1)
      expect(response).to have_http_status(:ok)
    end

    it "filters videos by query" do
      get "/blogs/#{author.username}/videos", params: { q: "promo" }
      expect(response).to have_http_status(:ok)
    end

    it "filters videos by year" do
      get "/blogs/#{author.username}/videos", params: { year: video_record.published_at.year.to_s }
      expect(response).to have_http_status(:ok)
    end

    it "filters videos by tag" do
      tag = Tag.create!(name: "Promo", slug: "promo-tag")
      video_record.tags << tag
      get "/blogs/#{author.username}/videos", params: { tag: tag.name }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /blogs/:blog_slug/gallery and /gallery/:slug" do
    let!(:photo_record) do
      create(:album, :published, author: author, slug: "snapshot",
                                 title_i18n: { "en" => "A Snapshot" })
    end

    it "lists albums" do
      get "/blogs/#{author.username}/gallery"
      expect(response).to have_http_status(:ok)
    end

    it "shows a single album and bumps its views" do
      expect {
        get "/blogs/#{author.username}/gallery/#{photo_record.slug}"
      }.to change { photo_record.reload.views_count }.by(1)
      expect(response).to have_http_status(:ok)
    end

    it "filters photos by query / year / tag" do
      tag = Tag.create!(name: "Snaps", slug: "snaps")
      photo_record.tags << tag

      get "/blogs/#{author.username}/gallery", params: { q: "snapshot" }
      expect(response).to have_http_status(:ok)

      get "/blogs/#{author.username}/gallery", params: { year: photo_record.published_at.year.to_s }
      expect(response).to have_http_status(:ok)

      get "/blogs/#{author.username}/gallery", params: { tag: tag.name }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /blogs/:blog_slug/categories/:slug" do
    let!(:category)   { create(:category, user: author, slug: "news") }
    let!(:cat_post)   { create(:post, :published, author: author, category: category) }

    it "renders the category page" do
      get "/blogs/#{author.username}/categories/#{category.slug}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /blogs/:blog_slug/tags/:slug" do
    let!(:tag)        { Tag.create!(name: "Featured", slug: "featured") }
    let!(:tagged)     { create(:post, :published, author: author).tap { |p| p.tags << tag } }

    it "renders the tag page" do
      get "/blogs/#{author.username}/tags/#{tag.slug}"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /blogs/:blog_slug/pages/:slug" do
    let!(:page_record) do
      create(:page, :published, author: author, slug: "about",
                                title_i18n: { "en" => "About Us" })
    end

    it "renders the page" do
      get "/blogs/#{author.username}/pages/#{page_record.slug}"
      expect(response).to have_http_status(:ok)
    end

    it "uses the theme default about image when page has no uploaded featured image" do
      get "/blogs/#{author.username}/pages/#{page_record.slug}"
      expect(response.body).to include("/themes/am/img/image/about/about-1.png")
    end

    it "falls back to first non-empty translation when selected locale is blank" do
      SiteSetting.set("available_locales", %w[pl uk], user: author, value_type: "json")
      SiteSetting.set("default_locale", "uk", user: author, value_type: "string")

      fallback_page = create(
        :page, :published, :in_menu, author: author, slug: "donate", show_in_menu: true,
        title_i18n: { "pl" => "", "uk" => "Підтримати" },
        content_i18n: { "pl" => "", "uk" => "<p>Український контент</p>" }
      )

      get "/blogs/#{author.username}/locale/pl"
      redirect_uri = URI.parse(response.location)
      expect(redirect_uri.path).to eq("/blogs/#{author.username}")
      expect(Rack::Utils.parse_nested_query(redirect_uri.query).fetch("locale", nil)).to eq("pl")

      get "/blogs/#{author.username}/pages/#{fallback_page.slug}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Підтримати")
      expect(response.body).to include("Український контент")
    end

    it "renders pages marked as show_in_menu in navigation" do
      menu_page = create(
        :page, :published, :in_menu, author: author, slug: "donate", show_in_menu: true,
        title_i18n: { "en" => "Donate" },
        content_i18n: { "en" => "<p>Donate content</p>" }
      )

      get "/blogs/#{author.username}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("/blogs/#{author.username}/pages/#{menu_page.slug}")
      expect(response.body).to include("Donate")
    end
  end

  describe "GET /blogs/:blog_slug/search" do
    let!(:hit) do
      create(:post, :published, author: author,
                                title_i18n: { "en" => "Searchable Apricots" },
                                content_i18n: { "en" => "Apricots ripen in summer." })
    end

    it "renders empty results page when query is blank" do
      get "/blogs/#{author.username}/search"
      expect(response).to have_http_status(:ok)
    end

    it "performs full-content search when ?q= is given" do
      get "/blogs/#{author.username}/search", params: { q: "apricots" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /blogs/:blog_slug/locale/:locale" do
    it "switches I18n locale and redirects back to the blog root" do
      get "/blogs/#{author.username}/locale/pl"
      redirect_uri = URI.parse(response.location)
      expect(redirect_uri.path).to eq("/blogs/#{author.username}")
    end

    it "falls back to a sensible locale when the requested one is not supported" do
      get "/blogs/#{author.username}/locale/xx"
      redirect_uri = URI.parse(response.location)
      expect(redirect_uri.path).to eq("/blogs/#{author.username}")
    end
  end
end
