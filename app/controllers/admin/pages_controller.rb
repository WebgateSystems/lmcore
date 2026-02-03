# frozen_string_literal: true

module Admin
  class PagesController < BaseController
    before_action :set_page, only: %i[show edit update destroy publish unpublish]

    def index
      authorize Page, policy_class: Admin::PagePolicy

      pages = policy_scope(Page, policy_scope_class: Admin::PagePolicy::Scope)
              .includes(:author)
              .order(sort_column => sort_direction)

      # Apply filters
      pages = pages.where(status: params[:status]) if params[:status].present?
      pages = pages.where("title_i18n::text ILIKE :q OR content_i18n::text ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @pages = pagy(pages, items: params[:per_page] || 25)
    end

    def show
      authorize @page, policy_class: Admin::PagePolicy
    end

    def new
      @page = Page.new
      authorize @page, policy_class: Admin::PagePolicy
    end

    def create
      @page = Page.new(page_params)
      @page.author = current_user
      authorize @page, policy_class: Admin::PagePolicy

      if @page.save
        log_action("create", @page)
        redirect_to admin_page_path(@page), notice: "Page created successfully."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @page, policy_class: Admin::PagePolicy
    end

    def update
      authorize @page, policy_class: Admin::PagePolicy

      if @page.update(page_params)
        log_action("update", @page)
        redirect_to admin_page_path(@page), notice: "Page updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @page, policy_class: Admin::PagePolicy

      @page.destroy
      log_action("delete", @page)
      redirect_to admin_pages_path, notice: "Page deleted successfully."
    end

    def publish
      authorize @page, policy_class: Admin::PagePolicy

      if @page.publish!
        log_action("publish", @page)
        redirect_to admin_page_path(@page), notice: "Page published successfully."
      else
        redirect_to admin_page_path(@page), alert: "Failed to publish page."
      end
    end

    def unpublish
      authorize @page, policy_class: Admin::PagePolicy

      if @page.unpublish!
        log_action("unpublish", @page)
        redirect_to admin_page_path(@page), notice: "Page unpublished."
      else
        redirect_to admin_page_path(@page), alert: "Failed to unpublish page."
      end
    end

    private

    def set_page
      @page = Page.find(params[:id])
    end

    def page_params
      params.require(:page).permit(
        :slug, :status, :show_in_menu, :menu_order,
        title_i18n: {}, content_i18n: {}, meta_description_i18n: {}, menu_title_i18n: {}
      )
    end

    def sort_column
      Page.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def log_action(action, page, details = {})
      AuditLog.create!(
        user: current_user,
        action: action,
        auditable: page,
        metadata: details.merge(page_title: page.title),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_id: request.request_id
      )
    end
  end
end
