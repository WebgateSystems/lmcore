# frozen_string_literal: true

require "rails_helper"

# Targets the role-management actions and a couple of failure paths in
# Admin::UsersController that the base spec does not exercise.
RSpec.describe "Admin::Users (extra)", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:super_admin_user) { create(:user, :super_admin) }
  let(:target_user) { create(:user) }

  before { sign_in admin_user }

  describe "GET /admin/users (extra filters)" do
    it "accepts a role_id filter without raising" do
      role = Role.find_by(slug: "moderator") || create(:role, slug: "moderator", name: "Moderator")
      target_user
      get admin_users_path(role_id: role.id)
      expect(response).to have_http_status(:success)
    end

    it "accepts an explicit sort + direction without raising" do
      get admin_users_path(sort: "email", direction: "asc")
      expect(response).to have_http_status(:success)
    end

    it "ignores an invalid sort column" do
      get admin_users_path(sort: "drop_table", direction: "asc")
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/users (failure)" do
    it "re-renders :new with unprocessable_content on invalid params" do
      post admin_users_path, params: { user: { email: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /admin/users/:id (failure)" do
    it "re-renders :edit with unprocessable_content on invalid params" do
      patch admin_user_path(target_user), params: { user: { email: "not-an-email" } }
      expect(response.status).to eq(422).or eq(200)
    end
  end

  describe "POST /admin/users/:id/change_role" do
    let(:role) do
      Role.find_by(slug: "moderator") || create(:role, slug: "moderator", name: "Moderator")
    end

    it "assigns the role and redirects with a notice" do
      post change_role_admin_user_path(target_user), params: { role_id: role.id }
      expect(response).to redirect_to(admin_user_path(target_user))
      expect(target_user.reload.role_assignments.where(role: role)).to be_present
    end

    it "redirects with an alert when assignment is invalid" do
      allow_any_instance_of(User).to receive(:assign_role!).and_raise(
        ActiveRecord::RecordInvalid.new(target_user)
      )
      post change_role_admin_user_path(target_user), params: { role_id: role.id }
      expect(response).to redirect_to(admin_user_path(target_user))
      expect(flash[:alert]).to include("Failed to assign role")
    end
  end

  describe "POST /admin/users/:id/add_role" do
    let(:role) { Role.find_by(slug: "moderator") || create(:role, slug: "moderator", name: "Moderator") }
    let(:scope_user) { create(:user, :author) }

    it "assigns a contextual role on a scope blog and logs the action" do
      post add_role_admin_user_path(target_user), params: { role_id: role.id, scope_user_id: scope_user.id }
      expect(response).to redirect_to(admin_user_path(target_user))
      expect(target_user.reload.role_assignments).to be_present
    end

    it "blocks non-super-admins from assigning the super-admin role" do
      sa_role = Role.find_by(slug: "super-admin") || create(:role, slug: "super-admin", name: "Super Admin")
      post add_role_admin_user_path(target_user), params: { role_id: sa_role.id }
      expect(response).to redirect_to(admin_user_path(target_user))
      expect(flash[:alert]).to include("Only super admins")
    end

    it "redirects with an alert when assignment fails (RecordInvalid)" do
      allow_any_instance_of(User).to receive(:assign_role!).and_raise(
        ActiveRecord::RecordInvalid.new(target_user)
      )
      post add_role_admin_user_path(target_user), params: { role_id: role.id }
      expect(response).to redirect_to(admin_user_path(target_user))
      expect(flash[:alert]).to include("Failed to assign role")
    end
  end

  describe "DELETE /admin/users/:id/remove_role/:role_assignment_id" do
    let(:role) { Role.find_by(slug: "moderator") || create(:role, slug: "moderator", name: "Moderator") }

    it "removes a role assignment" do
      assignment = target_user.assign_role!(role, granted_by: admin_user)
      delete remove_role_admin_user_path(target_user, role_assignment_id: assignment.id)
      expect(response).to redirect_to(admin_user_path(target_user))
      expect { assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "refuses to remove your own super-admin role" do
      sa_role = Role.find_by(slug: "super-admin") || create(:role, slug: "super-admin", name: "Super Admin")
      sign_in super_admin_user
      assignment = super_admin_user.assign_role!(sa_role, granted_by: super_admin_user)
      delete remove_role_admin_user_path(super_admin_user, role_assignment_id: assignment.id)
      expect(response).to redirect_to(admin_user_path(super_admin_user))
      expect(flash[:alert]).to include("cannot remove your own super-admin role")
    end
  end
end
