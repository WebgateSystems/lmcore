# frozen_string_literal: true

class CreateNotificationWorker < ApplicationWorker
  sidekiq_options queue: :default

  def perform(user_id, notification_type, notifiable_type = nil, notifiable_id = nil, data = {})
    user = User.find_by(id: user_id)
    return unless user

    notifiable = nil
    if notifiable_type.present? && notifiable_id.present?
      notifiable = notifiable_type.constantize.find_by(id: notifiable_id)
    end

    Notification.create!(
      user: user,
      notification_type: notification_type,
      notifiable: notifiable,
      data: data
    )
  rescue StandardError => e
    Rails.logger.error("Failed to create notification: #{e.message}")
    raise
  end
end
