# frozen_string_literal: true

module Dashboard
  class TagsController < BaseController
    before_action :set_tag, only: %i[show edit update destroy]

    def index
      authorize Tag, policy_class: Dashboard::TagPolicy
      tags = policy_scope(Tag, policy_scope_class: Dashboard::TagPolicy::Scope).alphabetical
      @pagy, @tags = pagy(tags, items: 30)
    end

    def show
      authorize @tag, policy_class: Dashboard::TagPolicy
      redirect_to edit_dashboard_tag_path(@tag)
    end

    def new
      @tag = Tag.new
      authorize @tag, policy_class: Dashboard::TagPolicy
    end

    def create
      normalized_name = tag_params[:name].to_s.strip
      if request.format.json? && normalized_name.present?
        existing_tag = Tag.find_by("LOWER(name) = ?", normalized_name.downcase)
        if existing_tag
          authorize existing_tag, policy_class: Dashboard::TagPolicy
          render json: { id: existing_tag.id, name: existing_tag.name, slug: existing_tag.slug }, status: :ok
          return
        end
      end

      @tag = Tag.new(tag_params)
      authorize @tag, policy_class: Dashboard::TagPolicy

      respond_to do |format|
        if @tag.save
          format.html { redirect_to dashboard_tags_path, notice: t("dashboard.flash.tags.created") }
          format.json { render json: { id: @tag.id, name: @tag.name, slug: @tag.slug }, status: :created }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @tag, policy_class: Dashboard::TagPolicy
    end

    def update
      authorize @tag, policy_class: Dashboard::TagPolicy
      if @tag.update(tag_params)
        redirect_to dashboard_tags_path, notice: t("dashboard.flash.tags.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @tag, policy_class: Dashboard::TagPolicy
      @tag.destroy
      redirect_to dashboard_tags_path, notice: t("dashboard.flash.tags.deleted")
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :slug)
    end
  end
end
