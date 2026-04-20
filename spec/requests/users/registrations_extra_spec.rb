# frozen_string_literal: true

require "rails_helper"

# Targets account-update / locale-clamping branches that the invitation-flow
# spec does not exercise.
RSpec.describe "Users::Registrations (extra)", type: :request do
  let(:user) do
    create(:user,
           password: "password123",
           password_confirmation: "password123")
  end

  describe "GET /users/edit (locale clamping)" do
    it "renders successfully when the current locale is not blog-allowed" do
      sign_in user
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return([ "en" ])
      I18n.with_locale(:pl) do
        get edit_user_registration_path
        expect(response).to have_http_status(:success)
      end
    end

    it "renders successfully when the current locale is blog-allowed (no clamp)" do
      sign_in user
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return([ "en", "pl" ])
      I18n.with_locale(:pl) do
        get edit_user_registration_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /users (without password change)" do
    before { sign_in user }

    it "updates first_name without requiring current_password" do
      patch user_registration_path, params: {
        user: {
          first_name: "Updated",
          last_name: user.last_name,
          email: user.email
        }
      }
      expect(user.reload.first_name).to eq("Updated")
    end
  end

  describe "PATCH /users (with password change)" do
    before { sign_in user }

    it "updates the password when current_password is correct" do
      patch user_registration_path, params: {
        user: {
          current_password: "password123",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
      expect(response).to have_http_status(:redirect).or have_http_status(:success)
      # Sign in with the new password to confirm it actually changed.
      user.reload
      expect(user.valid_password?("newpassword123")).to be true
    end

    it "fails when current_password is wrong" do
      patch user_registration_path, params: {
        user: {
          current_password: "totally-wrong",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
      expect(user.reload.valid_password?("password123")).to be true
    end
  end

  describe "locale sanitization on profile update" do
    let(:author) { create(:user, :author, password: "password123", password_confirmation: "password123") }

    before { sign_in author }

    it "clamps an unsupported user-supplied locale to a blog-allowed one" do
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return([ "en" ])
      patch user_registration_path, params: {
        user: { locale: "xx-YY", first_name: author.first_name, email: author.email }
      }
      expect(author.reload.locale).to eq("en")
    end

    it "keeps a supported locale verbatim" do
      allow(SiteSetting).to receive(:blog_available_locale_codes_for).and_return([ "en", "pl" ])
      patch user_registration_path, params: {
        user: { locale: "pl", first_name: author.first_name, email: author.email }
      }
      expect(author.reload.locale).to eq("pl")
    end
  end
end
