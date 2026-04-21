# frozen_string_literal: true

module Dashboard
  class PagesController < BaseController
    before_action :set_page, only: %i[show edit update destroy]

    def index
      authorize Page, policy_class: Dashboard::PagePolicy
      pages = policy_scope(Page, policy_scope_class: Dashboard::PagePolicy::Scope)
              .order(Arel.sql("COALESCE(published_at, created_at) DESC"))
      pages = pages.where(status: params[:status]) if params[:status].present?
      @pagy, @pages = pagy(pages, items: 20)
    end

    def show
      authorize @page, policy_class: Dashboard::PagePolicy
      redirect_to edit_dashboard_page_path(@page)
    end

    def new
      @page = Page.new
      authorize @page, policy_class: Dashboard::PagePolicy
    end

    def create
      @page = Page.new(page_params)
      @page.author = current_user
      authorize @page, policy_class: Dashboard::PagePolicy

      if @page.save
        redirect_to dashboard_pages_path, notice: t("dashboard.flash.pages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @page, policy_class: Dashboard::PagePolicy
    end

    def update
      authorize @page, policy_class: Dashboard::PagePolicy
      if @page.update(page_params)
        redirect_to dashboard_pages_path, notice: t("dashboard.flash.pages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @page, policy_class: Dashboard::PagePolicy
      @page.discard
      redirect_to dashboard_pages_path, notice: t("dashboard.flash.pages.trashed")
    end

    private

    def set_page
      @page = scoped_pages.find(params[:id])
    end

    def page_params
      params.require(:page).permit(:title, :slug, :body, :status, :page_type,
                                   :show_in_menu, :meta_title, :meta_description,
                                   :published_at)
    end
  end
end
