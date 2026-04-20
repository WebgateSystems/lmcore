# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserGroupMembership, type: :model do
  let(:group) { create(:user_group) }
  let(:user)  { create(:user) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(%w[member moderator admin]) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user_group) }
    it { is_expected.to belong_to(:user) }
  end

  describe "scopes" do
    it ".admins / .moderators / .regular_members partition by role" do
      admin     = group.add_member(create(:user), role: "admin")
      moderator = group.add_member(create(:user), role: "moderator")
      member    = group.add_member(create(:user), role: "member")

      expect(UserGroupMembership.admins).to include(admin)
      expect(UserGroupMembership.moderators).to include(admin, moderator)
      expect(UserGroupMembership.regular_members).to contain_exactly(member)
    end
  end

  describe "role predicates" do
    it "admin? is true only for the admin role" do
      m = group.add_member(user, role: "admin")
      expect(m.admin?).to be true
      expect(m.moderator?).to be true # admin counts as moderator
      expect(m.member?).to be false
    end

    it "moderator? is true for moderator OR admin" do
      m = group.add_member(user, role: "moderator")
      expect(m.moderator?).to be true
      expect(m.admin?).to be false
    end

    it "member? is true only for plain members" do
      m = group.add_member(user, role: "member")
      expect(m.member?).to be true
    end
  end

  describe "promotions/demotions" do
    it "promote_to_moderator! moves a member up" do
      m = group.add_member(user, role: "member")
      m.promote_to_moderator!
      expect(m.reload.role).to eq("moderator")
    end

    it "promote_to_moderator! is a no-op for an admin" do
      m = group.add_member(user, role: "admin")
      m.promote_to_moderator!
      expect(m.reload.role).to eq("admin")
    end

    it "promote_to_admin! works regardless of current role" do
      m = group.add_member(user, role: "moderator")
      m.promote_to_admin!
      expect(m.reload.role).to eq("admin")
    end

    it "demote_to_member! demotes a moderator" do
      m = group.add_member(user, role: "moderator")
      m.demote_to_member!
      expect(m.reload.role).to eq("member")
    end

    it "demote_to_member! refuses to demote the group owner from admin" do
      m = group.user_group_memberships.find_by(user: group.owner)
      m.demote_to_member!
      expect(m.reload.role).to eq("admin")
    end
  end
end
