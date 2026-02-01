# frozen_string_literal: true

class DeviseCustomFailure < Devise::FailureApp
  def respond
    if request.format == :json || api_request?
      json_failure
    else
      super
    end
  end

  def json_failure
    self.status = :unauthorized
    self.content_type = "application/json"
    self.response_body = { error: i18n_message }.to_json
  end

  private

  def api_request?
    request.path.start_with?("/api/")
  end
end
