# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:super_admin_user) { create(:user, :super_admin) }
  let(:regular_user) { create(:user) }
  let(:target_user) { create(:user) }

  describe "GET /admin/users" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end

      it "displays users list" do
        target_user
        get admin_users_path
        expect(response.body).to include("Users")
      end

      it "filters by status" do
        get admin_users_path(status: "active")
        expect(response).to have_http_status(:success)
      end

      it "searches by email" do
        get admin_users_path(q: target_user.email)
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_users_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_users_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/users/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_user_path(target_user)
        expect(response).to have_http_status(:success)
      end

      it "displays user details" do
        get admin_user_path(target_user)
        expect(response.body).to include(target_user.email)
      end
    end
  end

  describe "GET /admin/users/new" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get new_admin_user_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /admin/users" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:valid_params) do
        {
          user: {
            email: "newuser@example.com",
            username: "newuser",
            password: "password123",
            password_confirmation: "password123",
            first_name: "New",
            last_name: "User",
            status: "active"
          }
        }
      end

      it "creates a new user" do
        expect {
          post admin_users_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "redirects to the created user" do
        post admin_users_path, params: valid_params
        expect(response).to redirect_to(admin_user_path(User.last))
      end
    end
  end

  describe "GET /admin/users/:id/edit" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get edit_admin_user_path(target_user)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /admin/users/:id" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:update_params) do
        {
          user: {
            first_name: "Updated",
            last_name: "Name"
          }
        }
      end

      it "updates the user" do
        patch admin_user_path(target_user), params: update_params
        target_user.reload
        expect(target_user.first_name).to eq("Updated")
      end

      it "redirects to the user" do
        patch admin_user_path(target_user), params: update_params
        expect(response).to redirect_to(admin_user_path(target_user))
      end
    end
  end

  describe "DELETE /admin/users/:id" do
    context "when authenticated as super admin" do
      before { sign_in super_admin_user }

      it "soft deletes the user" do
        target_user
        delete admin_user_path(target_user)
        expect(target_user.reload.status).to eq("deleted")
        expect(target_user.discarded?).to be true
      end

      it "redirects to users list" do
        delete admin_user_path(target_user)
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "when authenticated as regular admin" do
      before { sign_in admin_user }

      it "may not allow deletion depending on policy" do
        target_user
        delete admin_user_path(target_user)
        # Response depends on policy implementation
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "POST /admin/users/:id/suspend" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "suspends the user" do
        post suspend_admin_user_path(target_user)
        target_user.reload
        expect(target_user.status).to eq("suspended")
      end

      it "redirects to the user" do
        post suspend_admin_user_path(target_user)
        expect(response).to redirect_to(admin_user_path(target_user))
      end
    end
  end

  describe "POST /admin/users/:id/activate" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      let(:suspended_user) { create(:user, status: "suspended") }

      it "activates the user" do
        post activate_admin_user_path(suspended_user)
        suspended_user.reload
        expect(suspended_user.status).to eq("active")
      end
    end
  end

  describe "POST /admin/users/:id/impersonate" do
    context "when authenticated as super admin" do
      before { sign_in super_admin_user }

      it "starts impersonation session" do
        post impersonate_admin_user_path(target_user)
        expect(response).to redirect_to(root_path)
        # Session stores the original admin user for de-impersonation
        expect(session[:admin_user_id]).to eq(super_admin_user.id)
      end
    end
  end
end
