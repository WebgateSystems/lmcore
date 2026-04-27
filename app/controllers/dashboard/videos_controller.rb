# frozen_string_literal: true

module Dashboard
  class VideosController < BaseController
    before_action :set_video, only: %i[show edit update destroy create_post_from_video pin]

    def index
      authorize Video, policy_class: Dashboard::VideoPolicy
      videos = policy_scope(Video, policy_scope_class: Dashboard::VideoPolicy::Scope)
               .order(Arel.sql("COALESCE(published_at, created_at) DESC"))
      videos = videos.where(status: params[:status]) if params[:status].present?
      videos = videos.search_by_title(params[:q]) if params[:q].present?
      @pagy, @videos = pagy(videos, items: 20)
      @latest_sync_run = current_user.dashboard_job_runs.youtube_sync.recent_first.first
      @video_post_runs = current_user.dashboard_job_runs.video_to_post
                                   .where(video_id: @videos.map(&:id))
                                   .recent_first
                                   .group_by(&:video_id)
    end

    def show
      authorize @video, policy_class: Dashboard::VideoPolicy
      redirect_to edit_dashboard_video_path(@video)
    end

    def new
      @video = Video.new
      authorize @video, policy_class: Dashboard::VideoPolicy
      @categories = scoped_categories
    end

    def create
      @video = Video.new(video_params)
      @video.author = current_user
      authorize @video, policy_class: Dashboard::VideoPolicy

      if @video.save
        redirect_to dashboard_videos_path, notice: t("dashboard.flash.videos.created")
      else
        @categories = scoped_categories
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @video, policy_class: Dashboard::VideoPolicy
      @categories = scoped_categories
    end

    def update
      authorize @video, policy_class: Dashboard::VideoPolicy
      if @video.update(video_params)
        redirect_to dashboard_videos_path, notice: t("dashboard.flash.videos.updated")
      else
        @categories = scoped_categories
        render :edit, status: :unprocessable_entity
      end
    end

    # Hard-deletes the video, cascading comments + replies, reactions,
    # taggings, content visibilities, and media attachments (which in turn
    # deletes the underlying CarrierWave files). The dashboard surfaces this
    # as an irreversible action behind a confirmation modal — see
    # `data-confirm-destroy` in app/views/dashboard/videos/index.html.slim
    # and the modal infra in app/javascript/dashboard.js.
    def destroy
      authorize @video, policy_class: Dashboard::VideoPolicy
      @video.destroy!
      redirect_to dashboard_videos_path, notice: t("dashboard.flash.videos.deleted")
    end

    def sync_youtube
      authorize Video, :sync_youtube?, policy_class: Dashboard::VideoPolicy

      channel_url = SiteSetting.get("youtube_url", user: current_user, default: nil).presence ||
                    SiteSetting.get("social_youtube", user: current_user, default: nil).presence
      sync_locale = selected_sync_locale

      if channel_url.blank?
        redirect_to dashboard_videos_path, alert: t("dashboard.flash.videos.sync_channel_missing")
        return
      end

      job_run = current_user.dashboard_job_runs.create!(
        job_type: "youtube_sync",
        status: "queued",
        stage: "queued",
        payload: { channel_url: channel_url }
      )

      SyncYoutubeChannelVideosWorker.perform_async(
        current_user.id,
        channel_url,
        sync_locale,
        nil,
        job_run.id
      )

      redirect_to dashboard_videos_path, notice: t("dashboard.flash.videos.sync_enqueued")
    end

    def sync_status
      authorize Video, :sync_youtube?, policy_class: Dashboard::VideoPolicy

      run = current_user.dashboard_job_runs.youtube_sync.recent_first.first
      render json: serialize_job_run(run)
    end

    # Toggles this video as the single "Top video" on the public homepage
    # for the current author. See Publishable#toggle_pinned!.
    def pin
      authorize @video, policy_class: Dashboard::VideoPolicy
      pinned = @video.toggle_pinned!
      flash_key = pinned ? "dashboard.flash.videos.pinned" : "dashboard.flash.videos.unpinned"
      redirect_back fallback_location: dashboard_videos_path, notice: t(flash_key)
    end

    def create_post_from_video
      authorize @video, :create_post_from_video?, policy_class: Dashboard::VideoPolicy

      job_run = current_user.dashboard_job_runs.create!(
        job_type: "video_to_post",
        video: @video,
        status: "queued",
        stage: "queued",
        payload: { video_id: @video.id, video_external_id: @video.video_external_id }
      )

      CreatePostFromVideoSubtitlesWorker.perform_async(current_user.id, @video.id, job_run.id)
      redirect_to dashboard_videos_path, notice: t("dashboard.flash.videos.create_post_enqueued")
    end

    private

    def set_video
      @video = scoped_videos.find(params[:id])
    end

    def video_params
      attrs = params.require(:video).permit(
        :title, :slug, :body, :excerpt, :status, :category_id,
        :video_url, :video_provider, :video_file, :thumbnail,
        :meta_title, :meta_description, :published_at,
        title_i18n: {},
        subtitle_i18n: {},
        description_i18n: {},
        keywords_i18n: {},
        meta_description_i18n: {},
        tag_ids: []
      )

      locale = I18n.locale.to_s
      attrs[:title_i18n] = (attrs[:title_i18n] || {}).merge(locale => attrs[:title]) if attrs[:title].present?
      attrs[:subtitle_i18n] = (attrs[:subtitle_i18n] || {}).merge(locale => attrs[:excerpt]) if attrs[:excerpt].present?
      attrs[:description_i18n] = (attrs[:description_i18n] || {}).merge(locale => attrs[:body]) if attrs[:body].present?
      attrs[:meta_description_i18n] = (attrs[:meta_description_i18n] || {}).merge(locale => attrs[:meta_description]) if attrs[:meta_description].present?

      attrs.except(:title, :excerpt, :body, :meta_description, :meta_title)
    end

    def serialize_job_run(run)
      return { present: false } unless run

      {
        present: true,
        id: run.id,
        status: run.status,
        stage: run.stage,
        progress_current: run.progress_current,
        progress_total: run.progress_total,
        created_count: run.created_count,
        updated_count: run.updated_count,
        skipped_count: run.skipped_count,
        error_count: run.error_count,
        last_video_id: run.last_video_id,
        error_message: run.error_message,
        started_at: run.started_at,
        finished_at: run.finished_at
      }
    end

    def selected_sync_locale
      candidate = params[:sync_locale].to_s.strip.presence || I18n.locale.to_s
      available = dashboard_available_locales.presence || I18n.available_locales.map(&:to_s)
      available.include?(candidate) ? candidate : (current_user.locale.presence || I18n.default_locale.to_s)
    end
  end
end
