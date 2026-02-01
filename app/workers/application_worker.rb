# frozen_string_literal: true

class ApplicationWorker
  include Sidekiq::Job

  sidekiq_options retry: 3, backtrace: true

  # Override in subclasses if needed
  sidekiq_retries_exhausted do |job, exception|
    Rails.logger.error(
      "Job #{job['class']} with args #{job['args']} failed permanently: #{exception.message}"
    )
  end
end
