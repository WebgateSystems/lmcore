# frozen_string_literal: true

module Dashboard
  # Per-blog team management. The current user is always the blog owner --
  # cross-blog team management lives in /admin.
  class TeamController < BaseController
    before_action :load_assignment, only: %i[update_role destroy]

    def index
      authorize :team, :index?, policy_class: Dashboard::TeamPolicy
      @assignments = policy_scope(RoleAssignment, policy_scope_class: Dashboard::TeamPolicy::Scope)
                     .order("roles.priority DESC, users.email ASC")
                     .joins(:role, :user)
      @pending_invitations = policy_scope(Invitation, policy_scope_class: Dashboard::TeamInvitationPolicy::Scope)
                             .order(created_at: :desc)
      @available_roles = available_roles
      @new_invitation = Invitation.new
    end

    # POST /dashboard/team
    #
    # Adds a teammate by email. If the email already belongs to a registered
    # user, the role is granted immediately. Otherwise an Invitation is sent
    # and the role is granted automatically when the invitee completes
    # registration.
    def create
      authorize :team, :create?, policy_class: Dashboard::TeamPolicy

      email = team_params[:email].to_s.downcase.strip
      role_slug = team_params[:role_slug].to_s

      unless Invitation::BLOG_ROLE_SLUGS.include?(role_slug)
        redirect_to dashboard_team_index_path, alert: t("dashboard.team.flash.invalid_role")
        return
      end

      if (existing_user = User.find_by(email: email))
        add_existing_user(existing_user, role_slug)
      else
        create_invitation(email, role_slug)
      end
    end

    # PATCH /dashboard/team/:id
    def update_role
      authorize @assignment, :update_role?, policy_class: Dashboard::TeamPolicy

      new_slug = params.dig(:role_assignment, :role_slug).to_s
      unless Invitation::BLOG_ROLE_SLUGS.include?(new_slug)
        redirect_to dashboard_team_index_path, alert: t("dashboard.team.flash.invalid_role")
        return
      end

      new_role = Role.find_by(slug: new_slug)
      if new_role && @assignment.update(role: new_role)
        redirect_to dashboard_team_index_path, notice: t("dashboard.team.flash.role_updated")
      else
        redirect_to dashboard_team_index_path,
                    alert: t("dashboard.team.flash.update_failed", error: @assignment.errors.full_messages.to_sentence)
      end
    end

    # DELETE /dashboard/team/:id
    def destroy
      authorize @assignment, :destroy?, policy_class: Dashboard::TeamPolicy

      if @assignment.user_id == current_user.id
        redirect_to dashboard_team_index_path, alert: t("dashboard.team.flash.cannot_remove_self")
        return
      end

      @assignment.destroy
      redirect_to dashboard_team_index_path, notice: t("dashboard.team.flash.member_removed")
    end

    private

    def load_assignment
      @assignment = policy_scope(RoleAssignment, policy_scope_class: Dashboard::TeamPolicy::Scope)
                    .find(params[:id])
    end

    def team_params
      params.require(:team).permit(:email, :role_slug)
    end

    def available_roles
      Role.where(slug: Invitation::BLOG_ROLE_SLUGS).order(priority: :desc)
    end

    def add_existing_user(user, role_slug)
      role = Role.find_by(slug: role_slug)
      unless role
        redirect_to dashboard_team_index_path, alert: t("dashboard.team.flash.invalid_role")
        return
      end

      if RoleAssignment.for_blog(current_user).exists?(user_id: user.id)
        redirect_to dashboard_team_index_path, alert: t("dashboard.team.flash.already_member")
      else
        user.assign_role!(role, scope: current_user, granted_by: current_user)
        redirect_to dashboard_team_index_path, notice: t("dashboard.team.flash.member_added", email: user.email)
      end
    end

    def create_invitation(email, role_slug)
      invitation = Invitation.new(
        email: email,
        inviter: current_user,
        blog_owner: current_user,
        blog_role_slug: role_slug,
        role_type: "user"
      )

      if invitation.save
        redirect_to dashboard_team_index_path, notice: t("dashboard.team.flash.invitation_sent", email: email)
      else
        redirect_to dashboard_team_index_path,
                    alert: t("dashboard.team.flash.invitation_failed", error: invitation.errors.full_messages.to_sentence)
      end
    end
  end
end
