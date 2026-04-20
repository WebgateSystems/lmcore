# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserGroup, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_presence_of(:visibility) }
    it { is_expected.to validate_inclusion_of(:visibility).in_array(%w[private public]) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:owner).class_name("User") }
    it { is_expected.to have_many(:user_group_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:user_group_memberships) }
    it { is_expected.to have_many(:content_visibilities).dependent(:destroy) }
  end

  describe "scopes" do
    let!(:public_group)  { create(:user_group, :public) }
    let!(:private_group) { create(:user_group) }

    it ".public_groups / .private_groups split by visibility" do
      expect(UserGroup.public_groups).to contain_exactly(public_group)
      expect(UserGroup.private_groups).to contain_exactly(private_group)
    end

    it ".by_owner filters by owner" do
      expect(UserGroup.by_owner(public_group.owner)).to contain_exactly(public_group)
    end

    it ".with_member returns groups the user belongs to" do
      member = create(:user)
      private_group.add_member(member)
      expect(UserGroup.with_member(member)).to include(private_group)
    end
  end

  describe "after_create :add_owner_as_admin" do
    it "automatically adds the owner as an admin member" do
      group = create(:user_group)
      expect(group.user_group_memberships.where(user: group.owner, role: "admin")).to exist
    end
  end

  describe "#public? / #private?" do
    it { expect(build(:user_group, :public)).to be_public }
    it { expect(build(:user_group, visibility: "private")).to be_private }
  end

  describe "#add_member" do
    let(:group)  { create(:user_group) }
    let(:member) { create(:user) }

    it "creates a membership with default role 'member'" do
      group.add_member(member)
      expect(group.user_group_memberships.find_by(user: member).role).to eq("member")
    end

    it "is idempotent — adding twice does not duplicate the membership" do
      group.add_member(member)
      expect { group.add_member(member) }.not_to change(group.user_group_memberships, :count)
    end

    it "accepts a custom role" do
      group.add_member(member, role: "moderator")
      expect(group.user_group_memberships.find_by(user: member).role).to eq("moderator")
    end
  end

  describe "#remove_member" do
    let(:group)  { create(:user_group) }
    let(:member) { create(:user) }

    it "removes the member" do
      group.add_member(member)
      expect { group.remove_member(member) }.to change(group.user_group_memberships, :count).by(-1)
    end

    it "refuses to remove the owner" do
      expect(group.remove_member(group.owner)).to be false
    end
  end

  describe "#member? / #admin? / #moderator?" do
    let(:group) { create(:user_group) }

    it "owner is automatically admin and moderator" do
      expect(group.admin?(group.owner)).to be true
      expect(group.moderator?(group.owner)).to be true
    end

    it "regular members are members but not admin/moderator" do
      m = create(:user)
      group.add_member(m)
      expect(group.member?(m)).to be true
      expect(group.admin?(m)).to be false
      expect(group.moderator?(m)).to be false
    end

    it "moderator role registers as moderator but not admin" do
      m = create(:user)
      group.add_member(m, role: "moderator")
      expect(group.moderator?(m)).to be true
      expect(group.admin?(m)).to be false
    end
  end

  describe "#set_role" do
    let(:group)  { create(:user_group) }
    let(:member) { create(:user) }

    it "updates the role of an existing membership" do
      group.add_member(member)
      group.set_role(member, "admin")
      expect(group.admin?(member)).to be true
    end

    it "is a no-op for non-members" do
      expect { group.set_role(create(:user), "admin") }.not_to raise_error
    end
  end

  describe "#transfer_ownership" do
    let(:group)     { create(:user_group) }
    let(:new_owner) { create(:user) }

    it "transfers ownership when the new owner is a member" do
      group.add_member(new_owner)
      old_owner = group.owner

      expect(group.transfer_ownership(new_owner)).to be true
      expect(group.reload.owner).to eq(new_owner)
      expect(group.admin?(old_owner)).to be true
      expect(group.admin?(new_owner)).to be true
    end

    it "refuses to transfer ownership to a non-member" do
      expect(group.transfer_ownership(create(:user))).to be false
    end
  end
end
