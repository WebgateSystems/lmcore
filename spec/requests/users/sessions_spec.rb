# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let!(:user) { create(:user, email: "session@example.com", password: "password123", password_confirmation: "password123") }

  it "redirects to safe return_to after sign in" do
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      },
      return_to: "/blogs/am/posts"
    }

    expect(response).to redirect_to("/blogs/am/posts")
  end

  it "ignores unsafe return_to and falls back to root" do
    post user_session_path, params: {
      user: {
        email: user.email,
        password: "password123"
      },
      return_to: "//evil.example"
    }

    expect(response).to redirect_to(root_path)
  end
end
