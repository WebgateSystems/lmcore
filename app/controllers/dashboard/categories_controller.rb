# frozen_string_literal: true

module Dashboard
  class CategoriesController < BaseController
    before_action :set_category, only: %i[show edit update destroy]

    def index
      authorize Category, policy_class: Dashboard::CategoryPolicy
      @categories = policy_scope(Category, policy_scope_class: Dashboard::CategoryPolicy::Scope)
                    .ordered
    end

    def show
      authorize @category, policy_class: Dashboard::CategoryPolicy
      redirect_to edit_dashboard_category_path(@category)
    end

    def new
      @category = Category.new
      authorize @category, policy_class: Dashboard::CategoryPolicy
      @parent_categories = scoped_categories.roots
    end

    def create
      @category = Category.new(category_params)
      @category.user = dashboard_blog_user
      authorize @category, policy_class: Dashboard::CategoryPolicy

      if @category.save
        redirect_to dashboard_categories_path, notice: t("dashboard.flash.categories.created")
      else
        @parent_categories = scoped_categories.roots
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @category, policy_class: Dashboard::CategoryPolicy
      @parent_categories = scoped_categories.roots.where.not(id: @category.id)
    end

    def update
      authorize @category, policy_class: Dashboard::CategoryPolicy
      if @category.update(category_params)
        redirect_to dashboard_categories_path, notice: t("dashboard.flash.categories.updated")
      else
        @parent_categories = scoped_categories.roots.where.not(id: @category.id)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @category, policy_class: Dashboard::CategoryPolicy
      @category.destroy
      redirect_to dashboard_categories_path, notice: t("dashboard.flash.categories.deleted")
    end

    private

    def set_category
      @category = scoped_categories.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :slug, :description, :parent_id, :category_type, :position)
    end
  end
end
