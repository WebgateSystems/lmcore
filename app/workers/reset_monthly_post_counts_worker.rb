# frozen_string_literal: true

class ResetMonthlyPostCountsWorker < ApplicationWorker
  sidekiq_options queue: :low

  def perform
    # Reset posts_this_month counter for all users at the start of each month
    User.update_all(posts_this_month: 0)
    Rails.logger.info("Reset monthly post counts for all users")
  end
end
