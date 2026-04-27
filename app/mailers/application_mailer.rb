# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Settings.services.smtp.from
  layout "mailer"
end
