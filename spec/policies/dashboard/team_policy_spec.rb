# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::TeamPolicy, type: :policy do
  let(:owner) { create(:user, :author) }
  let(:other_owner) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:visitor) { create(:user) }

  let(:editor_role) do
    Role.find_by(slug: "editor") || (
      r = Role.new(
        slug: "editor",
        name_i18n: { "en" => "Editor" },
        description_i18n: { "en" => "Editor" },
        permissions: [],
        priority: 40,
        system_role: true
      )
      r.write_attribute(:name, "Editor")
      r.save!
      r
    )
  end

  let(:teammate) { create(:user) }
  let(:assignment) do
    teammate.assign_role!(editor_role, scope: owner, granted_by: owner)
  end

  describe "#index?" do
    it "is permitted for any dashboard user" do
      expect(described_class.new(owner, :team).index?).to be true
      expect(described_class.new(moderator, :team).index?).to be true
    end

    it "is not permitted for users without dashboard role" do
      expect(described_class.new(visitor, :team).index?).to be false
    end
  end

  describe "#update_role? / #destroy?" do
    it "is permitted only for the blog owner" do
      policy = described_class.new(owner, assignment)
      expect(policy.update_role?).to be true
      expect(policy.destroy?).to be true
    end

    it "is denied for moderators looking at another blog (no cross-blog bypass)" do
      policy = described_class.new(moderator, assignment)
      expect(policy.update_role?).to be false
      expect(policy.destroy?).to be false
    end

    it "is denied for any other dashboard user" do
      policy = described_class.new(other_owner, assignment)
      expect(policy.update_role?).to be false
      expect(policy.destroy?).to be false
    end
  end

  describe Dashboard::TeamPolicy::Scope do
    it "returns only role assignments scoped to the current user's blog" do
      mine = teammate.assign_role!(editor_role, scope: owner, granted_by: owner)
      other = create(:user).assign_role!(editor_role, scope: other_owner, granted_by: other_owner)

      scope = described_class.new(owner, RoleAssignment.all).resolve
      expect(scope).to include(mine)
      expect(scope).not_to include(other)
    end

    it "returns nothing for users without a dashboard role" do
      teammate.assign_role!(editor_role, scope: owner, granted_by: owner)
      scope = described_class.new(visitor, RoleAssignment.all).resolve
      expect(scope).to be_empty
    end
  end
end
