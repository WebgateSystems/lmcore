# frozen_string_literal: true

# We don't (and shouldn't) need a live Redis to run RSpec.
#
# Several model callbacks fan-out to Sidekiq workers (e.g. `Comment` enqueues
# `NotifyCommentAuthorWorker` after_create). In `:real` Sidekiq mode that
# triggers a TCP connection to Redis at job-enqueue time and blows up on CI:
#
#     RedisClient::CannotConnectError: Connection refused (redis://localhost:6379)
#
# `:fake` mode pushes jobs into an in-memory array (`Worker.jobs`) instead of
# Redis. Specs that *want* to assert on enqueued jobs can still introspect
# `Worker.jobs`; specs that want jobs to actually run can wrap the example in
# `Sidekiq::Testing.inline!` themselves.

require "sidekiq/testing"

Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
