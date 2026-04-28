# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action :store_return_to_location, only: %i[new create]

    private

    def store_return_to_location
      return_to = params[:return_to].to_s
      return if return_to.blank?
      return unless return_to.start_with?("/")
      return if return_to.start_with?("//")

      session[:user_return_to] = return_to
    end
  end
end
