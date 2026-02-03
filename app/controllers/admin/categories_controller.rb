# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: %i[show edit update destroy]

    def index
      authorize Category, policy_class: Admin::CategoryPolicy

      categories = policy_scope(Category, policy_scope_class: Admin::CategoryPolicy::Scope)
                   .order(sort_column => sort_direction)

      # Apply filters
      categories = categories.where("name_i18n::text ILIKE :q OR slug ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @categories = pagy(categories, items: params[:per_page] || 25)
    end

    def show
      authorize @category, policy_class: Admin::CategoryPolicy
    end

    def new
      @category = Category.new
      authorize @category, policy_class: Admin::CategoryPolicy
    end

    def create
      @category = Category.new(category_params)
      @category.user = current_user
      authorize @category, policy_class: Admin::CategoryPolicy

      if @category.save
        log_action("create", @category)
        redirect_to admin_category_path(@category), notice: "Category created successfully."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @category, policy_class: Admin::CategoryPolicy
    end

    def update
      authorize @category, policy_class: Admin::CategoryPolicy

      if @category.update(category_params)
        log_action("update", @category)
        redirect_to admin_category_path(@category), notice: "Category updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @category, policy_class: Admin::CategoryPolicy

      @category.destroy
      log_action("delete", @category)
      redirect_to admin_categories_path, notice: "Category deleted successfully."
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:slug, :parent_id, :category_type, :position, name_i18n: {}, description_i18n: {})
    end

    def sort_column
      Category.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def log_action(action, category, details = {})
      AuditLog.create!(
        user: current_user,
        action: action,
        auditable: category,
        metadata: details.merge(category_name: category.name),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_id: request.request_id
      )
    end
  end
end
