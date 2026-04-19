# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitation, type: :model do
  let(:inviter) { create(:user) }
  let(:invitation) { create(:invitation, inviter: inviter) }

  describe "associations" do
    it { is_expected.to belong_to(:inviter).class_name("User") }
    it { is_expected.to belong_to(:invitee).class_name("User").optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending accepted expired cancelled]) }

    it "generates token automatically" do
      new_invitation = create(:invitation, inviter: inviter)
      expect(new_invitation.token).to be_present
    end

    it "validates uniqueness of token at database level" do
      invitation
      # Create a duplicate directly bypassing callback
      duplicate = Invitation.new(inviter: inviter, email: "other@example.com", status: "pending", expires_at: 7.days.from_now)
      duplicate.token = invitation.token
      expect { duplicate.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "scopes" do
    let!(:pending_invitation) { create(:invitation, inviter: inviter, status: "pending") }
    let!(:accepted_invitation) { create(:invitation, inviter: inviter, status: "accepted") }
    let!(:expired_invitation) { create(:invitation, inviter: inviter, status: "expired") }

    describe ".pending" do
      it "returns only pending invitations" do
        expect(described_class.pending).to include(pending_invitation)
        expect(described_class.pending).not_to include(accepted_invitation, expired_invitation)
      end
    end

    describe ".accepted" do
      it "returns only accepted invitations" do
        expect(described_class.accepted).to include(accepted_invitation)
      end
    end
  end

  describe "#accept!" do
    let(:invitee) { create(:user) }

    it "changes status to accepted" do
      invitation.accept!(invitee)
      expect(invitation.status).to eq("accepted")
      expect(invitation.invitee).to eq(invitee)
    end

    context "with a blog-team invitation" do
      let(:blog_owner) { create(:user, :author) }
      let(:invitation) do
        create(:invitation, :for_blog,
               inviter: blog_owner,
               blog_owner_user: blog_owner,
               blog_role_slug: "moderator")
      end

      it "grants the requested role on the blog owner's scope" do
        expect { invitation.accept!(invitee) }.to change {
          invitee.role_assignments.for_blog(blog_owner).count
        }.from(0).to(1)
        expect(invitee.has_role?("moderator", scope: blog_owner)).to be true
      end
    end
  end

  describe "blog invitation validations" do
    let(:blog_owner) { create(:user, :author) }

    it "requires blog_owner when blog_role_slug is set" do
      inv = build(:invitation, inviter: blog_owner, blog_role_slug: "editor", blog_owner: nil)
      expect(inv).not_to be_valid
      expect(inv.errors[:blog_role_slug]).to be_present
    end

    it "rejects blog_role_slug outside the allowed set" do
      inv = build(:invitation, :for_blog, inviter: blog_owner, blog_owner_user: blog_owner, blog_role_slug: "admin")
      expect(inv).not_to be_valid
      expect(inv.errors[:blog_role_slug]).to be_present
    end

    it "allows inviting an existing user when it is a team invitation" do
      existing = create(:user)
      inv = build(:invitation, :for_blog,
                  inviter: blog_owner,
                  blog_owner_user: blog_owner,
                  email: existing.email,
                  blog_role_slug: "editor")
      expect(inv).to be_valid
    end

    it "rejects inviting an existing team member twice" do
      existing = create(:user)
      role = Role.find_by(slug: "editor") || create(:role, slug: "editor", priority: 40, system_role: true)
      existing.assign_role!(role, scope: blog_owner, granted_by: blog_owner)

      inv = build(:invitation, :for_blog,
                  inviter: blog_owner,
                  blog_owner_user: blog_owner,
                  email: existing.email,
                  blog_role_slug: "editor")
      expect(inv).not_to be_valid
      expect(inv.errors[:email]).to be_present
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      invitation.update_column(:expires_at, 1.day.ago)
      expect(invitation.expired?).to be true
    end

    it "returns false when expires_at is in the future" do
      expect(invitation.expired?).to be false
    end
  end
end
