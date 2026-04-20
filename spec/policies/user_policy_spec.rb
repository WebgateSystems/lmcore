# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:admin)       { create(:user, :admin) }
  let(:super_admin) { create(:user, :super_admin) }
  let(:owner)       { create(:user) }
  let(:other)       { create(:user) }

  describe "open actions" do
    it "anyone can index/show/create" do
      p = described_class.new(nil, owner)
      expect(p.index?).to be true
      expect(p.show?).to be true
      expect(p.create?).to be true
    end
  end

  describe "#update?" do
    it "is true for the user themselves" do
      expect(described_class.new(owner, owner).update?).to be true
    end

    it "is true for an admin" do
      expect(described_class.new(admin, owner).update?).to be true
    end

    it "is false for a stranger" do
      expect(described_class.new(other, owner).update?).to be false
    end
  end

  describe "#destroy?" do
    it "is true for super_admin" do
      expect(described_class.new(super_admin, owner).destroy?).to be true
    end

    it "is true for the user themselves" do
      expect(described_class.new(owner, owner).destroy?).to be true
    end

    it "is false for a regular admin" do
      expect(described_class.new(admin, owner).destroy?).to be false
    end
  end

  describe "#suspend?" do
    it "is true for an admin acting on a non-admin" do
      expect(described_class.new(admin, owner).suspend?).to be true
    end

    it "is false for an admin acting on another admin" do
      other_admin = create(:user, :admin)
      expect(described_class.new(admin, other_admin).suspend?).to be false
    end

    it "is false for a non-admin" do
      expect(described_class.new(owner, other).suspend?).to be false
    end
  end

  describe "#activate?" do
    it "is true for an admin" do
      expect(described_class.new(admin, owner).activate?).to be true
    end

    it "is false for a regular user" do
      expect(described_class.new(owner, other).activate?).to be false
    end
  end

  describe "#change_role?" do
    it "requires super_admin" do
      expect(described_class.new(admin, owner).change_role?).to be false
      expect(described_class.new(super_admin, owner).change_role?).to be true
    end
  end

  describe "#change_plan?" do
    it "is true for the user themselves or for an admin" do
      expect(described_class.new(owner, owner).change_plan?).to be true
      expect(described_class.new(admin, owner).change_plan?).to be true
      expect(described_class.new(other, owner).change_plan?).to be false
    end
  end

  describe "#impersonate?" do
    it "is true for super_admin acting on a non-super_admin" do
      expect(described_class.new(super_admin, owner).impersonate?).to be true
    end

    it "is false for super_admin acting on another super_admin" do
      other_sa = create(:user, :super_admin)
      expect(described_class.new(super_admin, other_sa).impersonate?).to be false
    end

    it "is false for a regular admin" do
      expect(described_class.new(admin, owner).impersonate?).to be false
    end
  end

  describe "Scope" do
    let!(:active)    { create(:user, status: "active") }
    let!(:suspended) { create(:user, status: "suspended") }

    it "regular users see active+kept users only" do
      results = UserPolicy::Scope.new(owner, User).resolve
      expect(results).to include(active)
      expect(results).not_to include(suspended)
    end

    it "admins see everyone" do
      results = UserPolicy::Scope.new(admin, User).resolve
      expect(results).to include(active, suspended)
    end
  end
end
