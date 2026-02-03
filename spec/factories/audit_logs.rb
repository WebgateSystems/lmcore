# frozen_string_literal: true

FactoryBot.define do
  factory :audit_log do
    association :user
    action { "create" }
    association :auditable, factory: :user
    metadata { {} }
    changes_data { {} }
    ip_address { "127.0.0.1" }
    user_agent { "RSpec Test Agent" }
    request_id { SecureRandom.uuid }
  end
end
