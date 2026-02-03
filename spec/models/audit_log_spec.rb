# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuditLog, type: :model do
  let(:user) { create(:user) }
  let(:auditable) { user }
  let(:audit_log) { create(:audit_log, user: user, auditable: auditable) }

  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:auditable) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_presence_of(:auditable_type) }
    it { is_expected.to validate_presence_of(:auditable_id) }
  end

  describe "scopes" do
    let!(:create_log) { create(:audit_log, user: user, auditable: user, action: "create") }
    let!(:update_log) { create(:audit_log, user: user, auditable: user, action: "update") }
    let!(:delete_log) { create(:audit_log, user: user, auditable: user, action: "destroy") }
    let!(:old_log) { create(:audit_log, user: user, auditable: user, action: "create", created_at: 2.days.ago) }

    describe ".by_action" do
      it "filters by action" do
        expect(described_class.by_action("create")).to include(create_log, old_log)
        expect(described_class.by_action("create")).not_to include(update_log, delete_log)
      end
    end

    describe ".by_user" do
      it "filters by user" do
        other_user = create(:user)
        other_log = create(:audit_log, user: other_user, auditable: other_user, action: "create")

        expect(described_class.by_user(user)).to include(create_log, update_log)
        expect(described_class.by_user(user)).not_to include(other_log)
      end
    end

    describe ".recent" do
      it "orders by created_at desc" do
        logs = described_class.recent
        expect(logs.first.created_at).to be > logs.last.created_at
      end
    end
  end

  describe "#metadata" do
    it "stores and retrieves metadata as JSON" do
      audit_log.update!(metadata: { key: "value", nested: { inner: "data" } })
      audit_log.reload

      expect(audit_log.metadata["key"]).to eq("value")
      expect(audit_log.metadata["nested"]["inner"]).to eq("data")
    end
  end

  describe ".log" do
    it "creates a new audit log entry" do
      post = create(:post)
      initial_count = described_class.count
      described_class.log(
        action: "test_action",
        auditable: post,
        metadata: { test: "data" }
      )
      expect(described_class.count).to be > initial_count
    end
  end

  describe "#description" do
    it "returns description for create action" do
      log = create(:audit_log, action: "create", auditable: user)
      expect(log.description).to include("Created")
    end

    it "returns description for update action" do
      log = create(:audit_log, action: "update", auditable: user, changes_data: { "name" => [ "old", "new" ] })
      expect(log.description).to include("Updated")
    end
  end
end
