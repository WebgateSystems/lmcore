# frozen_string_literal: true

module Dashboard
  class PhotosController < BaseController
    before_action :set_photo, only: %i[show edit update destroy pin]

    def index
      authorize Photo, policy_class: Dashboard::PhotoPolicy
      photos = policy_scope(Photo, policy_scope_class: Dashboard::PhotoPolicy::Scope)
               .order(Arel.sql("COALESCE(published_at, created_at) DESC"))
      photos = photos.where(status: params[:status]) if params[:status].present?
      photos = photos.search_by_title(params[:q]) if params[:q].present?
      @pagy, @photos = pagy(photos, items: 20)
    end

    def show
      authorize @photo, policy_class: Dashboard::PhotoPolicy
      redirect_to edit_dashboard_photo_path(@photo)
    end

    def new
      @photo = Photo.new
      authorize @photo, policy_class: Dashboard::PhotoPolicy
      @categories = scoped_categories
    end

    def create
      @photo = Photo.new(photo_params)
      @photo.author = current_user
      authorize @photo, policy_class: Dashboard::PhotoPolicy

      if @photo.save
        redirect_to dashboard_photos_path, notice: t("dashboard.flash.photos.created")
      else
        @categories = scoped_categories
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @photo, policy_class: Dashboard::PhotoPolicy
      @categories = scoped_categories
    end

    def update
      authorize @photo, policy_class: Dashboard::PhotoPolicy
      if @photo.update(photo_params)
        redirect_to dashboard_photos_path, notice: t("dashboard.flash.photos.updated")
      else
        @categories = scoped_categories
        render :edit, status: :unprocessable_entity
      end
    end

    # Hard-deletes the photo, cascading comments + replies, reactions,
    # taggings, content visibilities, and media attachments. CarrierWave's
    # destroy hook then unlinks the underlying image file from storage. The
    # dashboard guards this action with a confirmation modal — see
    # `data-confirm-destroy` in app/views/dashboard/photos/index.html.slim
    # and the modal infra in app/javascript/dashboard.js.
    def destroy
      authorize @photo, policy_class: Dashboard::PhotoPolicy
      @photo.destroy!
      redirect_to dashboard_photos_path, notice: t("dashboard.flash.photos.deleted")
    end

    # Toggles this photo as the single "Top photo" on the public homepage
    # for the current author. See Publishable#toggle_pinned!.
    def pin
      authorize @photo, policy_class: Dashboard::PhotoPolicy
      pinned = @photo.toggle_pinned!
      flash_key = pinned ? "dashboard.flash.photos.pinned" : "dashboard.flash.photos.unpinned"
      redirect_back fallback_location: dashboard_photos_path, notice: t(flash_key)
    end

    private

    def set_photo
      @photo = scoped_photos.find(params[:id])
    end

    def photo_params
      params.require(:photo).permit(:title, :slug, :description, :status, :category_id,
                                    :image, :alt_text, :keywords,
                                    :published_at, tag_ids: [])
    end
  end
end
