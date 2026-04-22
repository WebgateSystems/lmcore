# frozen_string_literal: true

module Admin
  module Api
    module V1
      class BaseController < ActionController::API
        include Pundit::Authorization

        before_action :set_current_attributes
        before_action :authenticate_user!
        before_action :require_admin!

        # Pundit authorization
        after_action :verify_authorized, except: :index
        after_action :verify_policy_scoped, only: :index

        # Handle errors
        rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

        protected

        def set_current_attributes
          Current.user = current_user
          Current.request_id = request.request_id
          Current.user_agent = request.user_agent
          Current.ip_address = request.remote_ip
        end

        def require_admin!
          return if current_user&.admin?

          render_error(I18n.t("errors.admin_required", default: "Admin access required"), status: :forbidden)
        end

        def require_super_admin!
          return if current_user&.super_admin?

          render_error(I18n.t("errors.super_admin_required", default: "Super admin access required"), status: :forbidden)
        end

        # Standard JSON response helpers
        def render_success(data = nil, status: :ok, meta: nil, **named_data)
          payload = named_data.presence || data || {}
          response = { success: true, data: payload }
          response[:meta] = meta if meta.present?
          render json: response, status: status
        end

        def render_error(message, status: :bad_request, errors: nil)
          response = { success: false, error: message }
          response[:errors] = errors if errors.present?
          render json: response, status: status
        end

        def render_forbidden(exception = nil)
          message = exception&.message || I18n.t("errors.forbidden", default: "Access denied")
          render_error(message, status: :forbidden)
        end

        def render_not_found(exception = nil)
          message = exception&.message || I18n.t("errors.not_found", default: "Resource not found")
          render_error(message, status: :not_found)
        end

        def render_unprocessable_entity(exception)
          render_error(
            I18n.t("errors.validation_failed", default: "Validation failed"),
            status: :unprocessable_entity,
            errors: exception.record.errors.full_messages
          )
        end

        private

        def pagination_meta(collection)
          {
            current_page: collection.current_page,
            total_pages: collection.total_pages,
            total_count: collection.total_count,
            per_page: collection.limit_value
          }
        end

        # Audit logging for admin actions
        def log_admin_action(action, resource, details = {})
          return unless current_user

          AuditLog.create!(
            user: current_user,
            action: action,
            auditable: resource,
            metadata: details.merge(
              ip_address: request.remote_ip,
              user_agent: request.user_agent
            )
          )
        end
      end
    end
  end
end
