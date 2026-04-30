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
      @page.author = dashboard_blog_user
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
      attrs = params.require(:page).permit(
        :title, :slug, :content, :body, :status, :page_type, :featured_image,
        :show_in_menu, :meta_title, :meta_description, :published_at, :content_format,
        title_i18n: {},
        content_i18n: {},
        meta_description_i18n: {}
      )
      attrs[:title_i18n] = normalized_i18n_hash(attrs[:title_i18n])
      attrs[:content_i18n] = normalized_i18n_hash(attrs[:content_i18n])
      attrs[:meta_description_i18n] = normalized_i18n_hash(attrs[:meta_description_i18n])

      locale = I18n.locale.to_s
      if attrs[:title].present?
        attrs[:title_i18n] ||= {}
        attrs[:title_i18n][locale] = attrs[:title]
      end
      if attrs[:content].present?
        attrs[:content_i18n] ||= {}
        attrs[:content_i18n][locale] = attrs[:content]
      end
      if attrs[:body].present?
        attrs[:content_i18n] ||= {}
        attrs[:content_i18n][locale] = attrs[:body]
      end
      if attrs[:meta_description].present?
        attrs[:meta_description_i18n] ||= {}
        attrs[:meta_description_i18n][locale] = attrs[:meta_description]
      end

      # Backward compatibility: older dashboard forms used `body`.
      # Return a plain Hash so `update` never receives nested strong-params
      # wrappers that can raise ActionController::UnfilteredParameters.
      payload = attrs.to_unsafe_h
                     .except("title", "content", "body", "meta_description", "meta_title", "content_format")
                     .compact

      requested_content_format = params.dig(:page, :content_format).presence || attrs[:content_format]
      if requested_content_format.to_s == "markdown"
        source_i18n = normalized_i18n_hash(params.dig(:page, :content_i18n)) ||
                      normalized_i18n_hash(payload["content_i18n"]) || {}
        payload["content_i18n"] = source_i18n.each_with_object({}) do |(key, value), rendered|
          rendered[key.to_s] = Posts::ContentRenderer.render_markdown(value.to_s)
        end
      end

      payload
    end

    def normalized_i18n_hash(value)
      case value
      when nil then nil
      when ActionController::Parameters then value.to_unsafe_h
      when Hash then value
      else nil
      end
    end
  end
end
