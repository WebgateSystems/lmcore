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

    it "returns description for destroy action" do
      log = create(:audit_log, action: "destroy", auditable: user)
      expect(log.description).to include("Deleted")
    end

    it "humanises arbitrary actions" do
      expect(create(:audit_log, action: "login", auditable: user).description).to eq("Login")
    end
  end

  describe "diff helpers" do
    let(:log) { create(:audit_log, user: user, auditable: user, action: "update", changes_data: { "email" => [ "old@x.com", "new@x.com" ], "status" => "active" }) }

    it "#changed_fields returns the keys of changes_data" do
      expect(log.changed_fields).to contain_exactly("email", "status")
    end

    it "#previous_value reads index 0 of an [old, new] pair" do
      expect(log.previous_value(:email)).to eq("old@x.com")
      expect(log.previous_value(:status)).to be_nil
    end

    it "#new_value reads index 1 of an [old, new] pair (or the value itself)" do
      expect(log.new_value(:email)).to eq("new@x.com")
      expect(log.new_value(:status)).to eq("active")
    end
  end

  describe "action predicates" do
    it { expect(build(:audit_log, action: "create")).to be_create }
    it { expect(build(:audit_log, action: "update")).to be_update }
    it { expect(build(:audit_log, action: "destroy")).to be_destroy }
  end

  describe ".cleanup_old_logs!" do
    it "deletes logs older than the cutoff" do
      old = create(:audit_log, user: user, auditable: user, created_at: 2.years.ago)
      fresh = create(:audit_log, user: user, auditable: user, created_at: 1.day.ago)
      described_class.cleanup_old_logs!(older_than: 1.year.ago)
      expect(described_class.where(id: old.id)).to be_empty
      expect(described_class.where(id: fresh.id)).to exist
    end
  end

  describe "remaining scopes" do
    let!(:create_log)  { create(:audit_log, user: user, auditable: user, action: "create") }
    let!(:update_log)  { create(:audit_log, user: user, auditable: user, action: "update") }
    let!(:destroy_log) { create(:audit_log, user: user, auditable: user, action: "destroy") }

    it ".creates / .updates / .destroys" do
      expect(described_class.creates).to include(create_log)
      expect(described_class.updates).to include(update_log)
      expect(described_class.destroys).to include(destroy_log)
    end

    it ".for_record filters by auditable" do
      other_user = create(:user)
      explicit_log = create(:audit_log, user: user, auditable: other_user, action: "create")
      results = described_class.for_record(other_user)
      # User creation triggers an automatic audit hook elsewhere, so we can
      # have more than one log for `other_user` -- we just need to assert
      # that filtering by auditable narrows to that user (i.e. it includes
      # our explicit log and excludes logs about `user`).
      expect(results).to include(explicit_log)
      expect(results.pluck(:auditable_id).uniq).to eq([ other_user.id ])
    end

    it ".in_period filters by created_at" do
      old = create(:audit_log, user: user, auditable: user, action: "create", created_at: 5.days.ago)
      results = described_class.in_period(1.day.ago, 1.day.from_now)
      expect(results).to include(create_log)
      expect(results).not_to include(old)
    end
  end
end
