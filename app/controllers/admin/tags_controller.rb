# frozen_string_literal: true

module Admin
  class TagsController < BaseController
    before_action :set_tag, only: %i[show edit update destroy]

    def index
      authorize Tag, policy_class: Admin::TagPolicy

      tags = policy_scope(Tag, policy_scope_class: Admin::TagPolicy::Scope)
             .order(sort_column => sort_direction)

      # Apply filters
      tags = tags.where("name ILIKE :q OR slug ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

      @pagy, @tags = pagy(tags, items: params[:per_page] || 50)
    end

    def show
      authorize @tag, policy_class: Admin::TagPolicy
    end

    def new
      @tag = Tag.new
      authorize @tag, policy_class: Admin::TagPolicy
    end

    def create
      @tag = Tag.new(tag_params)
      authorize @tag, policy_class: Admin::TagPolicy

      if @tag.save
        log_action("create", @tag)
        redirect_to admin_tag_path(@tag), notice: "Tag created successfully."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @tag, policy_class: Admin::TagPolicy
    end

    def update
      authorize @tag, policy_class: Admin::TagPolicy

      if @tag.update(tag_params)
        log_action("update", @tag)
        redirect_to admin_tag_path(@tag), notice: "Tag updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @tag, policy_class: Admin::TagPolicy

      @tag.destroy
      log_action("delete", @tag)
      redirect_to admin_tags_path, notice: "Tag deleted successfully."
    end

    private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name, :slug)
    end

    def sort_column
      Tag.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def log_action(action, tag, details = {})
      AuditLog.create!(
        user: current_user,
        action: action,
        auditable: tag,
        metadata: details.merge(tag_name: tag.name),
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        request_id: request.request_id
      )
    end
  end
end
