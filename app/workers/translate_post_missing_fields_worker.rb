# frozen_string_literal: true

class TranslatePostMissingFieldsWorker < ApplicationWorker
  sidekiq_options queue: :low

  def perform(user_id, post_id, job_run_id)
    user = User.find_by(id: user_id)
    post = Post.find_by(id: post_id, author_id: user_id)
    return unless user && post

    job_run = DashboardJobRun.find_by(id: job_run_id, user: user, post: post, job_type: "post_translation")
    return unless job_run

    request = job_run.payload.fetch("request")
    target_locales = Array(request["target_locales"])

    job_run.mark_running!(stage: "calling_assistant")

    result = Assistant::PostTranslationClient.new.call(
      source_locale: request.fetch("source_locale"),
      target_locales: target_locales,
      content: request.fetch("content"),
      content_format: request["content_format"].presence || "html",
      metadata: {
        post_id: post.id,
        blog_user_id: user.id,
        requested_by_id: request["requested_by_id"]
      }
    )

    job_run.mark_completed!(
      stage: "finished",
      payload: job_run.payload.merge("result" => result),
      stats: {
        processed: target_locales.size,
        created: 0,
        updated: target_locales.size,
        skipped: 0,
        errors: 0
      }
    )
  rescue StandardError => e
    job_run&.mark_failed!(error_message: e.message, stage: "failed")
    raise
  end
end
