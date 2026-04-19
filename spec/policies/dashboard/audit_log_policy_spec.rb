# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::AuditLogPolicy, type: :policy do
  let(:author) { create(:user, :author) }
  let(:other_author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:visitor) { create(:user) }

  describe "#index?" do
    it "is permitted for any dashboard user" do
      expect(described_class.new(author, AuditLog).index?).to be true
      expect(described_class.new(moderator, AuditLog).index?).to be true
    end

    it "is not permitted without a dashboard role" do
      expect(described_class.new(visitor, AuditLog).index?).to be false
    end
  end

  describe "#show?" do
    it "is permitted when the audit log was performed by the user" do
      log = create(:audit_log, user: author)
      expect(described_class.new(author, log).show?).to be true
    end

    it "is permitted when the audit log targets the user's own content" do
      post = create(:post, author: author)
      log = create(:audit_log, auditable: post, user: other_author)
      expect(described_class.new(author, log).show?).to be true
    end

    it "is not permitted for unrelated logs (even for moderators)" do
      foreign_post = create(:post, author: other_author)
      log = create(:audit_log, auditable: foreign_post, user: other_author)
      expect(described_class.new(author, log).show?).to be false
      expect(described_class.new(moderator, log).show?).to be false
    end
  end

  describe Dashboard::AuditLogPolicy::Scope do
    it "returns audit logs for the user's own content" do
      mine_post = create(:post, author: author)
      mine_log = create(:audit_log, auditable: mine_post, user: other_author)
      foreign_log = create(:audit_log, auditable: create(:post, author: other_author), user: other_author)

      scope = described_class.new(author, AuditLog.all).resolve
      expect(scope).to include(mine_log)
      expect(scope).not_to include(foreign_log)
    end

    it "also returns audit logs the user themselves performed" do
      foreign_post = create(:post, author: other_author)
      acted_log = create(:audit_log, auditable: foreign_post, user: author)

      scope = described_class.new(author, AuditLog.all).resolve
      expect(scope).to include(acted_log)
    end

    it "limits moderators to their own scope (dashboard is per-blog)" do
      mine_post = create(:post, author: moderator)
      mine_log = create(:audit_log, auditable: mine_post, user: other_author)
      foreign_log = create(:audit_log, auditable: create(:post, author: other_author), user: other_author)

      scope = described_class.new(moderator, AuditLog.all).resolve
      expect(scope).to include(mine_log)
      expect(scope).not_to include(foreign_log)
    end
  end
end
