# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.base_controller_class = [ "ActionController::Base", "ActionController::API" ]
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    {
      request_id: event.payload[:request_id],
      user_id: event.payload[:user_id],
      ip: event.payload[:ip],
      user_agent: event.payload[:user_agent],
      params: event.payload[:params]&.except("controller", "action", "format", "password", "password_confirmation"),
      time: Time.current.iso8601
    }
  end

  config.lograge.custom_payload do |controller|
    {
      request_id: controller.request.request_id,
      user_id: controller.current_user&.id,
      ip: controller.request.remote_ip,
      user_agent: controller.request.user_agent
    }
  end
end
