# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :request_id
  attribute :user_agent
  attribute :ip_address
  attribute :locale

  resets do
    Time.zone = nil
    I18n.locale = I18n.default_locale
  end

  def user=(user)
    super
    Time.zone = user&.timezone || "UTC"
    I18n.locale = user&.locale&.to_sym || I18n.default_locale
  end
end
