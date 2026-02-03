# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::AuditLogs", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "GET /admin/audit_logs" do
    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_audit_logs_path
        expect(response).to have_http_status(:success)
      end

      it "displays audit logs list" do
        get admin_audit_logs_path
        expect(response.body).to include("Audit Logs")
      end

      it "filters by action" do
        get admin_audit_logs_path(action_filter: "create")
        expect(response).to have_http_status(:success)
      end

      it "filters by user" do
        get admin_audit_logs_path(user_id: admin_user.id)
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in regular_user }

      it "redirects to root" do
        get admin_audit_logs_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get admin_audit_logs_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /admin/audit_logs/:id" do
    let!(:audit_log) do
      AuditLog.create!(
        user: admin_user,
        action: "test_action",
        auditable: admin_user,
        metadata: { test: "data" },
        ip_address: "127.0.0.1",
        user_agent: "Test Agent",
        request_id: SecureRandom.uuid
      )
    end

    context "when authenticated as admin" do
      before { sign_in admin_user }

      it "returns success" do
        get admin_audit_log_path(audit_log)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
