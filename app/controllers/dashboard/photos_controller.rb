# frozen_string_literal: true

module Dashboard
  class PhotosController < BaseController
    before_action :set_photo, only: %i[show edit update destroy]

    def index
      authorize Photo, policy_class: Dashboard::PhotoPolicy
      photos = policy_scope(Photo, policy_scope_class: Dashboard::PhotoPolicy::Scope)
               .order(created_at: :desc)
      photos = photos.where(status: params[:status]) if params[:status].present?
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

    def destroy
      authorize @photo, policy_class: Dashboard::PhotoPolicy
      @photo.discard
      redirect_to dashboard_photos_path, notice: t("dashboard.flash.photos.trashed")
    end

    private

    def set_photo
      @photo = scoped_photos.find(params[:id])
    end

    def photo_params
      params.require(:photo).permit(:title, :slug, :body, :excerpt, :status, :category_id,
                                    :image, :alt_text, :meta_title, :meta_description,
                                    :published_at, tag_ids: [])
    end
  end
end
