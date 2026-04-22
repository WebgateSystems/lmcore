# frozen_string_literal: true

module Dashboard
  class AlbumsController < BaseController
    before_action :set_album, only: %i[show edit update destroy pin]

    def index
      authorize Album, policy_class: Dashboard::AlbumPolicy
      albums = policy_scope(Album, policy_scope_class: Dashboard::AlbumPolicy::Scope)
               .includes(:category, :cover_photo)
               .order(Arel.sql("COALESCE(published_at, created_at) DESC"))
      albums = albums.where(status: params[:status]) if params[:status].present?
      albums = albums.search_by_title(params[:q]) if params[:q].present?
      @pagy, @albums = pagy(albums, items: 20)
    end

    def show
      authorize @album, policy_class: Dashboard::AlbumPolicy
      redirect_to edit_dashboard_gallery_path(@album.slug)
    end

    def new
      @album = Album.new
      authorize @album, policy_class: Dashboard::AlbumPolicy
      load_form_collections
    end

    def create
      @album = Album.new(album_params)
      @album.author = current_user
      authorize @album, policy_class: Dashboard::AlbumPolicy

      if @album.save
        redirect_to edit_dashboard_gallery_path(@album.slug), notice: t("dashboard.flash.gallery.created")
      else
        load_form_collections
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @album, policy_class: Dashboard::AlbumPolicy
      load_form_collections
      @photos = @album.photos
    end

    def update
      authorize @album, policy_class: Dashboard::AlbumPolicy
      if @album.update(album_params)
        redirect_to edit_dashboard_gallery_path(@album.slug), notice: t("dashboard.flash.gallery.updated")
      else
        load_form_collections
        @photos = @album.photos
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @album, policy_class: Dashboard::AlbumPolicy
      @album.destroy!
      redirect_to dashboard_gallery_index_path, notice: t("dashboard.flash.gallery.deleted")
    end

    def pin
      authorize @album, policy_class: Dashboard::AlbumPolicy
      pinned = @album.toggle_pinned!
      flash_key = pinned ? "dashboard.flash.gallery.pinned" : "dashboard.flash.gallery.unpinned"
      redirect_back fallback_location: dashboard_gallery_index_path, notice: t(flash_key)
    end

    private

    def set_album
      @album = scoped_albums.find_by!(slug: params[:slug])
    end

    def scoped_albums
      Album.where(author: current_user)
    end

    def album_params
      params.require(:album).permit(:title, :slug, :description, :status, :category_id, :keywords, :published_at, tag_ids: [])
    end

    def load_form_collections
      @categories = scoped_categories
      @available_tags = policy_scope(Tag, policy_scope_class: Dashboard::TagPolicy::Scope).alphabetical
    end
  end
end
