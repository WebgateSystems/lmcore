# frozen_string_literal: true

module Dashboard
  class CommentsController < BaseController
    before_action :set_comment, only: %i[show update destroy]

    def index
      authorize Comment, policy_class: Dashboard::CommentPolicy
      comments = policy_scope(Comment, policy_scope_class: Dashboard::CommentPolicy::Scope)
                 .includes(:user, :commentable).order(created_at: :desc)
      comments = comments.where(status: params[:status]) if params[:status].present?
      @pagy, @comments = pagy(comments, items: 25)
    end

    def show
      authorize @comment, policy_class: Dashboard::CommentPolicy
    end

    def update
      authorize @comment, policy_class: Dashboard::CommentPolicy
      if @comment.update(comment_params)
        redirect_to dashboard_comments_path, notice: t("dashboard.flash.comments.updated")
      else
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @comment, policy_class: Dashboard::CommentPolicy
      @comment.discard
      redirect_to dashboard_comments_path, notice: t("dashboard.flash.comments.deleted")
    end

    private

    # Only look up comments inside the user's own blog scope. Any attempt to
    # access a comment from another author's blog returns 404 -- the dashboard
    # is intentionally siloed even for moderators/admins (cross-blog tools
    # belong in /admin).
    def set_comment
      @comment = policy_scope(Comment, policy_scope_class: Dashboard::CommentPolicy::Scope).find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:status)
    end
  end
end
