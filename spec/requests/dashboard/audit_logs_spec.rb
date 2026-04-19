# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard::AuditLogs", type: :request do
  describe "as a regular author" do
    let(:author) { create(:user, :author) }

    before { sign_in author }

    it "renders the index showing only own-scope entries" do
      mine = create(:audit_log, user: author)
      foreign = create(:audit_log)

      get dashboard_audit_logs_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(mine.id)
      expect(response.body).not_to include(foreign.id)
    end

    it "404s when fetching an unrelated audit log" do
      foreign = create(:audit_log)
      get dashboard_audit_log_path(foreign)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "as a moderator (still per-blog under /dashboard)" do
    let(:moderator) { create(:user, :moderator) }

    before { sign_in moderator }

    it "renders the index" do
      create(:audit_log, user: moderator)
      get dashboard_audit_logs_path
      expect(response).to have_http_status(:success)
    end

    it "does not surface unrelated audit logs" do
      foreign = create(:audit_log)
      get dashboard_audit_logs_path
      expect(response).not_to have_http_status(:redirect)
      expect(response.body).not_to include(foreign.id)
    end
  end
end
