# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::Team", type: :request do
  let(:owner) { create(:user, :author) }
  let(:other_owner) { create(:user, :author) }

  let(:editor_role) do
    Role.find_by(slug: "editor") || (
      r = Role.new(
        slug: "editor",
        name_i18n: { "en" => "Editor" },
        description_i18n: { "en" => "Editor" },
        permissions: [],
        priority: 40,
        system_role: true
      )
      r.write_attribute(:name, "Editor")
      r.save!
      r
    )
  end

  let(:moderator_role) do
    Role.find_by(slug: "moderator") || (
      r = Role.new(
        slug: "moderator",
        name_i18n: { "en" => "Moderator" },
        description_i18n: { "en" => "Moderator" },
        permissions: [],
        priority: 50,
        system_role: true
      )
      r.write_attribute(:name, "Moderator")
      r.save!
      r
    )
  end

  before do
    editor_role
    moderator_role
    sign_in owner
  end

  describe "GET /dashboard/team" do
    it "renders the page with team members and pending invitations" do
      teammate = create(:user)
      teammate.assign_role!(editor_role, scope: owner, granted_by: owner)
      create(:invitation, :for_blog, inviter: owner, blog_owner_user: owner, blog_role_slug: "moderator")

      get dashboard_team_index_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(teammate.email)
    end

    it "does not list role assignments from other blogs" do
      foreign = create(:user)
      foreign.assign_role!(editor_role, scope: other_owner, granted_by: other_owner)

      get dashboard_team_index_path
      expect(response.body).not_to include(foreign.email)
    end
  end

  describe "POST /dashboard/team" do
    context "when the email belongs to an existing user" do
      let!(:teammate) { create(:user, email: "teammate@example.com") }

      it "grants the role immediately, without creating an invitation" do
        expect {
          post dashboard_team_index_path, params: { team: { email: "teammate@example.com", role_slug: "editor" } }
        }.to change { teammate.reload.role_assignments.for_blog(owner).count }.by(1)
         .and change(Invitation, :count).by(0)
        expect(response).to redirect_to(dashboard_team_index_path)
      end

      it "rejects re-adding an existing collaborator" do
        teammate.assign_role!(editor_role, scope: owner, granted_by: owner)
        post dashboard_team_index_path, params: { team: { email: "teammate@example.com", role_slug: "editor" } }
        expect(flash[:alert]).to be_present
      end
    end

    context "when the email does not belong to any user" do
      it "creates a pending invitation scoped to the blog" do
        expect {
          post dashboard_team_index_path, params: { team: { email: "newperson@example.com", role_slug: "moderator" } }
        }.to change(Invitation, :count).by(1)

        invitation = Invitation.order(:created_at).last
        expect(invitation.blog_owner).to eq(owner)
        expect(invitation.blog_role_slug).to eq("moderator")
      end
    end

    it "rejects roles outside the blog-team allow-list" do
      post dashboard_team_index_path, params: { team: { email: "x@example.com", role_slug: "admin" } }
      expect(flash[:alert]).to be_present
      expect(Invitation.count).to eq(0)
    end
  end

  describe "PATCH /dashboard/team/:id/update_role" do
    let(:teammate) { create(:user) }
    let!(:assignment) { teammate.assign_role!(editor_role, scope: owner, granted_by: owner) }

    it "updates the role of a team member on the owner's blog" do
      patch update_role_dashboard_team_path(assignment),
            params: { role_assignment: { role_slug: "moderator" } }
      expect(assignment.reload.role).to eq(moderator_role)
    end

    it "404s when targeting an assignment from another blog" do
      foreign = create(:user).assign_role!(editor_role, scope: other_owner, granted_by: other_owner)
      patch update_role_dashboard_team_path(foreign), params: { role_assignment: { role_slug: "moderator" } }
      expect(response).to have_http_status(:not_found)
      expect(foreign.reload.role).to eq(editor_role)
    end
  end

  describe "DELETE /dashboard/team/:id" do
    let(:teammate) { create(:user) }
    let!(:assignment) { teammate.assign_role!(editor_role, scope: owner, granted_by: owner) }

    it "removes the team member" do
      expect { delete dashboard_team_path(assignment) }.to change(RoleAssignment, :count).by(-1)
    end

    it "404s when targeting an assignment from another blog" do
      foreign = create(:user).assign_role!(editor_role, scope: other_owner, granted_by: other_owner)
      delete dashboard_team_path(foreign)
      expect(response).to have_http_status(:not_found)
      expect(RoleAssignment.exists?(foreign.id)).to be true
    end
  end

  describe "DELETE /dashboard/team_invitations/:id" do
    let!(:invitation) do
      create(:invitation, :for_blog, inviter: owner, blog_owner_user: owner)
    end

    it "cancels the invitation" do
      delete dashboard_team_invitation_path(invitation)
      expect(invitation.reload.status).to eq("cancelled")
    end

    it "404s for invitations belonging to other blogs" do
      foreign = create(:invitation, :for_blog, inviter: other_owner, blog_owner_user: other_owner)
      delete dashboard_team_invitation_path(foreign)
      expect(response).to have_http_status(:not_found)
      expect(foreign.reload.status).to eq("pending")
    end
  end

  describe "POST /dashboard/team_invitations" do
    it "returns method_not_allowed (creation handled in team controller)" do
      post dashboard_team_invitations_path
      expect(response).to have_http_status(:method_not_allowed)
    end
  end

  describe "POST /dashboard/team_invitations/:id/resend" do
    let!(:invitation) do
      create(:invitation, :for_blog, inviter: owner, blog_owner_user: owner)
    end

    it "resends invitation and sets success flash" do
      allow_any_instance_of(Invitation).to receive(:resend!).and_return(true)
      post resend_dashboard_team_invitation_path(invitation)
      expect(response).to redirect_to(dashboard_team_index_path)
      expect(flash[:notice]).to be_present
    end

    it "shows alert when resend fails" do
      allow_any_instance_of(Invitation).to receive(:resend!).and_return(false)
      post resend_dashboard_team_invitation_path(invitation)
      expect(response).to redirect_to(dashboard_team_index_path)
      expect(flash[:alert]).to be_present
    end
  end
end
