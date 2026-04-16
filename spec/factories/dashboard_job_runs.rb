# frozen_string_literal: true

FactoryBot.define do
  factory :dashboard_job_run do
    association :user
    job_type { "youtube_sync" }
    status { "queued" }
    stage { "queued" }
    progress_current { 0 }
    progress_total { nil }
    payload { {} }
  end
end
