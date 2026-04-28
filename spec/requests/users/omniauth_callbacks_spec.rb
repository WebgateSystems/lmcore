# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  around do |example|
    original_test_mode = OmniAuth.config.test_mode
    original_request_validation_phase = OmniAuth.config.request_validation_phase

    OmniAuth.config.test_mode = true
    OmniAuth.config.request_validation_phase = proc { |_env| true }
    example.run
  ensure
    OmniAuth.config.test_mode = original_test_mode
    OmniAuth.config.request_validation_phase = original_request_validation_phase
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  it "signs in existing user by email and creates identity" do
    user = create(:user, email: "oauth@example.com", status: "active")
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "12345",
      info: {
        email: "oauth@example.com",
        name: "OAuth User"
      }
    )

    expect do
      post user_google_oauth2_omniauth_authorize_path
      follow_redirect! while response.redirect?
    end.to change(UserIdentity, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(UserIdentity.last.user).to eq(user)
  end

  it "reuses existing identity without creating another one" do
    user = create(:user, email: "known@example.com", status: "active")
    create(:user_identity, user: user, provider: "google_oauth2", uid: "existing-uid", email: user.email)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "existing-uid",
      info: {
        email: "known@example.com",
        name: "Known User"
      }
    )

    expect do
      post user_google_oauth2_omniauth_authorize_path
      follow_redirect! while response.redirect?
    end.not_to change(UserIdentity, :count)

    expect(response).to have_http_status(:ok)
  end

  it "creates a new user with fallback email when provider does not return email" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "no-email-uid",
      info: {
        name: "Ghost User",
        nickname: "ghost"
      }
    )

    expect do
      post user_google_oauth2_omniauth_authorize_path
      follow_redirect! while response.redirect?
    end.to change(User, :count).by(1).and change(UserIdentity, :count).by(1)

    created_user = User.order(:created_at).last
    expect(created_user.email).to eq("google_oauth2-no-email-uid@users.libremedia.local")
    expect(created_user.username).to start_with("ghost")
    expect(response).to have_http_status(:ok)
  end
end
