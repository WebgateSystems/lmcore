# frozen_string_literal: true

class PublishScheduledContentWorker < ApplicationWorker
  sidekiq_options queue: :critical

  def perform
    publish_scheduled_posts
    publish_scheduled_videos
    publish_scheduled_photos
  end

  private

  def publish_scheduled_posts
    Post.scheduled.where("scheduled_at <= ?", Time.current).find_each do |post|
      post.publish!
      Rails.logger.info("Published scheduled post: #{post.id}")
    rescue StandardError => e
      Rails.logger.error("Failed to publish post #{post.id}: #{e.message}")
    end
  end

  def publish_scheduled_videos
    Video.scheduled.where("scheduled_at <= ?", Time.current).find_each do |video|
      video.publish!
      Rails.logger.info("Published scheduled video: #{video.id}")
    rescue StandardError => e
      Rails.logger.error("Failed to publish video #{video.id}: #{e.message}")
    end
  end

  def publish_scheduled_photos
    Photo.scheduled.where("scheduled_at <= ?", Time.current).find_each do |photo|
      photo.publish!
      Rails.logger.info("Published scheduled photo: #{photo.id}")
    rescue StandardError => e
      Rails.logger.error("Failed to publish photo #{photo.id}: #{e.message}")
    end
  end
end
