# frozen_string_literal: true

class SendInvitationEmailWorker < ApplicationWorker
  sidekiq_options queue: :mailers

  def perform(invitation_id)
    invitation = Invitation.find_by(id: invitation_id)
    return unless invitation&.pending?

    # InvitationMailer.invitation_email(invitation).deliver_now
    Rails.logger.info("Sending invitation email to #{invitation.email}")
  end
end
