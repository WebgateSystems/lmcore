# frozen_string_literal: true

module Admin
  class PhotosController < BaseController
    before_action :set_photo, only: %i[show edit update destroy publish unpublish]

    def index
      authorize Photo, policy_class: Admin::PhotoPolicy

      photos = policy_scope(Photo, policy_scope_class: Admin::PhotoPolicy::Scope)
               .includes(:author)
               .order(sort_column => sort_direction)

      # Apply filters
      photos = photos.where(status: params[:status]) if params[:status].present?
      photos = photos.where(author_id: params[:author_id]) if params[:author_id].present?
      photos = photos.where("title_i18n::text ILIKE :q OR description_i18n::text ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @photos = pagy(photos, items: params[:per_page] || 25)
      @authors = User.joins(:photos).distinct.order(:username)
    end

    def show
      authorize @photo, policy_class: Admin::PhotoPolicy
    end

    def new
      @photo = Photo.new
      authorize @photo, policy_class: Admin::PhotoPolicy
    end

    def create
      @photo = Photo.new(photo_params)
      @photo.author = current_user
      authorize @photo, policy_class: Admin::PhotoPolicy

      if @photo.save
        log_action("create", @photo)
        redirect_to admin_photo_path(@photo), notice: "Photo created successfully."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @photo, policy_class: Admin::PhotoPolicy
    end

    def update
      authorize @photo, policy_class: Admin::PhotoPolicy

      if @photo.update(photo_params)
        log_action("update", @photo)
        redirect_to admin_photo_path(@photo), notice: "Photo updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @photo, policy_class: Admin::PhotoPolicy

      @photo.destroy
      log_action("delete", @photo)
      redirect_to admin_photos_path, notice: "Photo deleted successfully."
    end

    def publish
      authorize @photo, policy_class: Admin::PhotoPolicy

      if @photo.publish!
        log_action("publish", @photo)
        redirect_to admin_photo_path(@photo), notice: "Photo published successfully."
      else
        redirect_to admin_photo_path(@photo), alert: "Failed to publish photo."
      end
    end

    def unpublish
      authorize @photo, policy_class: Admin::PhotoPolicy

      if @photo.unpublish!
        log_action("unpublish", @photo)
        redirect_to admin_photo_path(@photo), notice: "Photo unpublished."
      else
        redirect_to admin_photo_path(@photo), alert: "Failed to unpublish photo."
      end
    end

    private

    def set_photo
      @photo = Photo.find(params[:id])
    end

    def photo_params
      params.require(:photo).permit(
        :status, :image, :category_id,
        title_i18n: {}, description_i18n: {}, alt_text_i18n: {}, keywords_i18n: {}
      )
    end

    def sort_column
      Photo.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def log_action(action, photo, details = {})
      AuditLog.create!(
        user: current_user,
        action: action,
        auditable: photo,
        metadata: details.merge(photo_title: photo.title),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_id: request.request_id
      )
    end
  end
end
