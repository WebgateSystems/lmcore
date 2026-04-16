# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::AuditLogs", type: :request do
  describe "as a non-moderator" do
    let(:author) { create(:user, :author) }
    before { sign_in author }

    it "redirects the index to the dashboard root" do
      get dashboard_audit_logs_path
      expect(response).to redirect_to(dashboard_root_path)
    end
  end

  describe "as a moderator" do
    let(:moderator) { create(:user, :moderator) }
    before { sign_in moderator }

    it "renders the index" do
      create(:audit_log, user: moderator)
      get dashboard_audit_logs_path
      expect(response).to have_http_status(:success)
    end
  end
end
