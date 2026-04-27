# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  layout false # MJML templates are self-contained

  default reply_to: Settings.services.smtp.reply_to
end
