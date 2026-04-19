# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /register?invitation_token=..." do
    let(:owner) { create(:user, :author) }
    let(:invitation) do
      create(:invitation, :for_blog,
             inviter: owner,
             blog_owner_user: owner,
             email: "newcomer@example.com",
             blog_role_slug: "moderator")
    end

    it "renders the form with the invitation email pre-filled" do
      get new_user_registration_path(invitation_token: invitation.token)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("newcomer@example.com")
      expect(response.body).to include(invitation.token)
    end
  end

  describe "POST /register with a valid invitation_token" do
    let!(:owner) { create(:user, :author) }
    let!(:invitation) do
      create(:invitation, :for_blog,
             inviter: owner,
             blog_owner_user: owner,
             email: "newcomer@example.com",
             blog_role_slug: "moderator")
    end

    it "creates the user and grants the invited role on the inviter's blog" do
      expect {
        post user_registration_path, params: {
          invitation_token: invitation.token,
          user: {
            email: "newcomer@example.com",
            password: "password123",
            password_confirmation: "password123",
            first_name: "New",
            last_name: "Comer",
            username: "newcomer"
          }
        }
      }.to change(User, :count).by(1)

      created = User.find_by(email: "newcomer@example.com")
      expect(created).to be_present
      expect(created.has_role?("moderator", scope: owner)).to be true
      expect(invitation.reload.status).to eq("accepted")
      expect(invitation.invitee).to eq(created)
    end

    it "ignores the invitation when the registered email does not match" do
      expect {
        post user_registration_path, params: {
          invitation_token: invitation.token,
          user: {
            email: "different@example.com",
            password: "password123",
            password_confirmation: "password123",
            first_name: "Diff",
            last_name: "Erent",
            username: "different"
          }
        }
      }.to change(User, :count).by(1)

      expect(invitation.reload.status).to eq("pending")

      created = User.find_by(email: "different@example.com")
      expect(created.has_role?("moderator", scope: owner)).to be false
    end
  end
end
