# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::AuditLogPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:admin) { create(:user, :admin) }
  let(:record) { create(:audit_log) }

  context "when user is only an author" do
    let(:user) { author }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:show) }
  end

  context "when user is a moderator" do
    let(:user) { moderator }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
  end

  context "when user is an admin" do
    let(:user) { admin }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
  end

  describe Dashboard::AuditLogPolicy::Scope do
    it "returns none for regular authors" do
      create(:audit_log)
      scope = described_class.new(author, AuditLog.all).resolve
      expect(scope).to be_empty
    end

    it "returns all audit logs for moderators" do
      log = create(:audit_log)
      scope = described_class.new(moderator, AuditLog.all).resolve
      expect(scope).to include(log)
    end
  end
end
