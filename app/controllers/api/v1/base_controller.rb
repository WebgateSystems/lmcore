# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :set_current_attributes
      before_action :set_locale
      before_action :authenticate_user!

      # Pundit authorization
      after_action :verify_authorized, except: :index, unless: :skip_authorization?
      after_action :verify_policy_scoped, only: :index, unless: :skip_authorization?

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
        Current.locale = I18n.locale
      end

      def set_locale
        locale = request.headers["Accept-Language"]&.scan(/^[a-z]{2}/)&.first ||
                 current_user&.locale ||
                 I18n.default_locale
        I18n.locale = locale if I18n.available_locales.map(&:to_s).include?(locale.to_s)
      end

      def render_success(data = {}, status: :ok)
        render json: { success: true, data: data }, status: status
      end

      def render_error(message, status: :bad_request, errors: nil)
        response = { success: false, error: message }
        response[:errors] = errors if errors.present?
        render json: response, status: status
      end

      def render_forbidden(exception = nil)
        message = exception&.message || t("errors.forbidden")
        render_error(message, status: :forbidden)
      end

      def render_not_found(exception = nil)
        message = exception&.message || t("errors.not_found")
        render_error(message, status: :not_found)
      end

      def render_unprocessable_entity(exception)
        render_error(
          t("errors.validation_failed"),
          status: :unprocessable_entity,
          errors: exception.record.errors.full_messages
        )
      end

      private

      def skip_authorization?
        false
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
