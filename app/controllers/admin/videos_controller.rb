# frozen_string_literal: true

module Admin
  class VideosController < BaseController
    before_action :set_video, only: %i[show edit update destroy publish unpublish]

    def index
      authorize Video, policy_class: Admin::VideoPolicy

      videos = policy_scope(Video, policy_scope_class: Admin::VideoPolicy::Scope)
               .includes(:author)
               .order(sort_column => sort_direction)

      # Apply filters
      videos = videos.where(status: params[:status]) if params[:status].present?
      videos = videos.where(author_id: params[:author_id]) if params[:author_id].present?
      videos = videos.where("title_i18n::text ILIKE :q OR description_i18n::text ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @videos = pagy(videos, items: params[:per_page] || 25)
      @authors = User.joins(:videos).distinct.order(:username)
    end

    def show
      authorize @video, policy_class: Admin::VideoPolicy
    end

    def new
      @video = Video.new
      authorize @video, policy_class: Admin::VideoPolicy
    end

    def create
      @video = Video.new(video_params)
      @video.author = current_user
      authorize @video, policy_class: Admin::VideoPolicy

      if @video.save
        log_action("create", @video)
        redirect_to admin_video_path(@video), notice: "Video created successfully."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @video, policy_class: Admin::VideoPolicy
    end

    def update
      authorize @video, policy_class: Admin::VideoPolicy

      if @video.update(video_params)
        log_action("update", @video)
        redirect_to admin_video_path(@video), notice: "Video updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @video, policy_class: Admin::VideoPolicy

      @video.destroy
      log_action("delete", @video)
      redirect_to admin_videos_path, notice: "Video deleted successfully."
    end

    def publish
      authorize @video, policy_class: Admin::VideoPolicy

      if @video.publish!
        log_action("publish", @video)
        redirect_to admin_video_path(@video), notice: "Video published successfully."
      else
        redirect_to admin_video_path(@video), alert: "Failed to publish video."
      end
    end

    def unpublish
      authorize @video, policy_class: Admin::VideoPolicy

      if @video.unpublish!
        log_action("unpublish", @video)
        redirect_to admin_video_path(@video), notice: "Video unpublished."
      else
        redirect_to admin_video_path(@video), alert: "Failed to unpublish video."
      end
    end

    private

    def set_video
      @video = Video.find(params[:id])
    end

    def video_params
      params.require(:video).permit(
        :status, :video_provider, :video_external_id, :thumbnail,
        :duration, :category_id,
        title_i18n: {}, subtitle_i18n: {}, description_i18n: {},
        keywords_i18n: {}, meta_description_i18n: {}
      )
    end

    def sort_column
      Video.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def log_action(action, video, details = {})
      AuditLog.create!(
        user: current_user,
        action: action,
        auditable: video,
        metadata: details.merge(video_title: video.title),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_id: request.request_id
      )
    end
  end
end
