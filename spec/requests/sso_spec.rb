# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sso", type: :request do
  let(:callback_uri) { "http://www.example.com/sso/callback" }

  before do
    allow(Sso::ClientApplication).to receive(:ensure_for_redirect!).and_return(true)
  end

  describe "GET /sso/login" do
    it "stores return path and redirects to issuer authorization endpoint" do
      get sso_login_path(return_to: "/blogs/am/posts")

      expect(response).to have_http_status(:found)

      location = response.headers["Location"]
      expect(location).to start_with("#{Settings.sso.issuer}/oauth/authorize?")

      query = Rack::Utils.parse_query(URI.parse(location).query)
      expect(query["client_id"]).to eq(Settings.sso.client_uid)
      expect(query["redirect_uri"]).to eq(callback_uri)
      expect(query["response_type"]).to eq("code")
      expect(query["scope"]).to include("openid")
      expect(query["state"]).to be_present
      expect(query["nonce"]).to be_present
    end

    it "redirects signed-in central users back to a vanity handoff endpoint" do
      user = create(:user, status: "active")
      create(:user, username: "amg", vanity_domain: "amg.example", status: "active")
      sign_in user

      get sso_login_path(target_origin: "http://amg.example", return_to: "/videos/story")

      expect(response).to have_http_status(:found)
      location = URI.parse(response.headers["Location"])
      expect("#{location.scheme}://#{location.host}").to eq("http://amg.example")
      expect(location.path).to eq("/sso/consume")
      expect(Rack::Utils.parse_query(location.query)["token"]).to be_present
    end

    it "sends logged-out central users through login before vanity handoff" do
      create(:user, username: "amg", vanity_domain: "amg.example", status: "active")

      get sso_login_path(target_origin: "http://amg.example", return_to: "/videos/story")

      expect(URI.parse(response.headers["Location"]).path).to eq("/login")
      expect(response.headers["Location"]).to include("return_to=")
      expect(response.headers["Location"]).to include("target_origin")
    end

    it "sanitizes external return_to values" do
      user = create(:user, status: "active")
      get sso_login_path(return_to: "//evil.example")
      state = Rack::Utils.parse_query(URI.parse(response.headers["Location"]).query).fetch("state")

      token_record = instance_double(
        Doorkeeper::AccessToken,
        resource_owner_id: user.id,
        revoked?: false,
        expired?: false
      )
      allow(Doorkeeper::AccessToken).to receive(:find_by).with(token: "sanitized-return-token").and_return(token_record)

      allow(Faraday).to receive(:post).and_return(
        instance_double(Faraday::Response, success?: true, body: { access_token: "sanitized-return-token" }.to_json)
      )

      get sso_callback_path(state: state, code: "auth-code")

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /sso/callback" do
    let!(:user) { create(:user, status: "active") }

    it "signs in and redirects to remembered return path" do
      get sso_login_path(return_to: "/blogs/am/pages/about")
      login_redirect = response.headers["Location"]
      state = Rack::Utils.parse_query(URI.parse(login_redirect).query).fetch("state")

      token_record = instance_double(
        Doorkeeper::AccessToken,
        resource_owner_id: user.id,
        revoked?: false,
        expired?: false
      )
      allow(Doorkeeper::AccessToken).to receive(:find_by).with(token: "access-token-123").and_return(token_record)

      allow(Faraday).to receive(:post).and_return(
        instance_double(Faraday::Response, success?: true, body: { access_token: "access-token-123" }.to_json)
      )

      get sso_callback_path(state: state, code: "auth-code")

      expect(response).to redirect_to("/blogs/am/pages/about")
    end

    it "rejects callback when state does not match" do
      get sso_callback_path(state: "bad-state", code: "auth-code")

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects to login when token exchange fails" do
      get sso_login_path
      state = Rack::Utils.parse_query(URI.parse(response.headers["Location"]).query).fetch("state")

      allow(Faraday).to receive(:post).and_return(
        instance_double(Faraday::Response, success?: false, body: "{}")
      )

      get sso_callback_path(state: state, code: "auth-code")

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end

    it "redirects to login when token points to inactive user" do
      inactive_user = create(:user, status: "suspended")
      get sso_login_path
      state = Rack::Utils.parse_query(URI.parse(response.headers["Location"]).query).fetch("state")

      token_record = instance_double(
        Doorkeeper::AccessToken,
        resource_owner_id: inactive_user.id,
        revoked?: false,
        expired?: false
      )
      allow(Doorkeeper::AccessToken).to receive(:find_by).with(token: "inactive-user-token").and_return(token_record)

      allow(Faraday).to receive(:post).and_return(
        instance_double(Faraday::Response, success?: true, body: { access_token: "inactive-user-token" }.to_json)
      )

      get sso_callback_path(state: state, code: "auth-code")

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end
  end

  describe "GET /sso/consume" do
    it "signs in on the vanity domain and redirects to the original path" do
      user = create(:user, status: "active")
      create(:user, username: "amg", vanity_domain: "amg.example", status: "active")
      sign_in user

      get sso_login_path(target_origin: "http://amg.example", return_to: "/videos/story")
      token = Rack::Utils.parse_query(URI.parse(response.headers["Location"]).query).fetch("token")

      get sso_consume_path(token: token), headers: { "HTTP_HOST" => "amg.example" }

      expect(response).to redirect_to("/videos/story")
    end

    it "rejects a handoff token on the wrong vanity domain" do
      user = create(:user, status: "active")
      create(:user, username: "amg", vanity_domain: "amg.example", status: "active")
      create(:user, username: "other", vanity_domain: "other.example", status: "active")
      sign_in user

      get sso_login_path(target_origin: "http://amg.example", return_to: "/videos/story")
      token = Rack::Utils.parse_query(URI.parse(response.headers["Location"]).query).fetch("token")

      get sso_consume_path(token: token), headers: { "HTTP_HOST" => "other.example" }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /sso/logout" do
    it "signs out the session on the vanity domain" do
      user = create(:user, status: "active")
      create(:user, username: "amg", vanity_domain: "amg.example", status: "active")
      sign_in user

      delete sso_logout_path, headers: { "HTTP_HOST" => "amg.example" }

      expect(response).to redirect_to(root_path)
      expect(request.env["warden"].user(:user)).to be_nil
    end
  end
end
