# frozen_string_literal: true

module Admin
  module Api
    module V1
      class ActivityController < BaseController
        def index
          authorize :admin_dashboard, :index?

          @activities = AuditLog.includes(:user)
                                .order(created_at: :desc)
                                .page(params[:page])
                                .per(params[:per_page] || 20)

          # Apply filters
          @activities = @activities.where(user_id: params[:user_id]) if params[:user_id].present?
          @activities = @activities.where(action: params[:action_type]) if params[:action_type].present?
          @activities = @activities.where(resource_type: params[:resource_type]) if params[:resource_type].present?
          @activities = @activities.where("created_at >= ?", params[:from].to_date) if params[:from].present?
          @activities = @activities.where("created_at <= ?", params[:to].to_date.end_of_day) if params[:to].present?

          render_success(
            activities: @activities.map { |log| activity_json(log) },
            meta: pagination_meta(@activities)
          )
        end

        private

        def activity_json(log)
          {
            id: log.id,
            action: log.action,
            resource_type: log.resource_type,
            resource_id: log.resource_id,
            details: log.details,
            created_at: log.created_at.iso8601,
            user: log.user ? {
              id: log.user.id,
              email: log.user.email,
              username: log.user.username,
              full_name: log.user.full_name
            } : nil
          }
        end
      end
    end
  end
end
