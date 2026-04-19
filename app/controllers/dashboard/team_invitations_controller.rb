# frozen_string_literal: true

module Dashboard
  class TeamInvitationsController < BaseController
    before_action :load_invitation, only: %i[destroy resend]

    def create
      # Creation is handled by TeamController#create (via the inline form on
      # the team page). This endpoint exists for API completeness.
      authorize Invitation, :create?, policy_class: Dashboard::TeamInvitationPolicy
      head :method_not_allowed
    end

    def destroy
      authorize @invitation, :destroy?, policy_class: Dashboard::TeamInvitationPolicy
      @invitation.cancel!
      redirect_to dashboard_team_index_path, notice: t("dashboard.team.flash.invitation_cancelled")
    end

    def resend
      authorize @invitation, :resend?, policy_class: Dashboard::TeamInvitationPolicy
      if @invitation.resend!
        redirect_to dashboard_team_index_path, notice: t("dashboard.team.flash.invitation_resent")
      else
        redirect_to dashboard_team_index_path, alert: t("dashboard.team.flash.invitation_resend_failed")
      end
    end

    private

    def load_invitation
      @invitation = Invitation.where(blog_owner_id: current_user.id).find(params[:id])
    end
  end
end
