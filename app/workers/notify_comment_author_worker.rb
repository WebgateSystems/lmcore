# frozen_string_literal: true

class NotifyCommentAuthorWorker < ApplicationWorker
  sidekiq_options queue: :default

  def perform(comment_id)
    comment = Comment.find_by(id: comment_id)
    return unless comment

    # Notify content author about new comment
    content_author = comment.commentable&.author
    return unless content_author && content_author != comment.user

    Notification.create!(
      user: content_author,
      actor: comment.user,
      notifiable: comment,
      notification_type: "new_comment",
      data: {
        content_type: comment.commentable_type,
        content_title: comment.commentable.try(:title)
      }
    )

    # If this is a reply, notify parent comment author
    if comment.parent.present?
      parent_author = comment.parent.user
      return unless parent_author && parent_author != comment.user && parent_author != content_author

      Notification.create!(
        user: parent_author,
        actor: comment.user,
        notifiable: comment,
        notification_type: "comment_reply",
        data: {}
      )
    end
  rescue StandardError => e
    Rails.logger.error("Failed to notify about comment: #{e.message}")
    raise
  end
end
