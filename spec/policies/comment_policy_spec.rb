# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentPolicy, type: :policy do
  subject(:policy) { described_class.new(user, comment) }

  let(:author)        { create(:user, :author) }
  let(:other_user)    { create(:user) }
  let(:moderator)     { create(:user, :moderator) }
  let(:admin)         { create(:user, :admin) }
  let(:post_record)   { create(:post, :published, author: author) }
  let(:comment) do
    post_record.comments.create!(user: other_user, content: "hi", status: "approved")
  end

  describe "#show?" do
    it "is true for an approved comment regardless of viewer" do
      expect(described_class.new(nil, comment).show?).to be true
    end

    it "is true for the author of the underlying content (content_owner)" do
      pending = post_record.comments.create!(user: other_user, content: "x", status: "pending")
      expect(described_class.new(author, pending).show?).to be true
    end

    it "is true for the comment author themselves on their pending comment" do
      pending = post_record.comments.create!(user: other_user, content: "x", status: "pending")
      expect(described_class.new(other_user, pending).show?).to be true
    end

    it "is false for a stranger on a pending comment" do
      pending = post_record.comments.create!(user: other_user, content: "x", status: "pending")
      stranger = create(:user)
      expect(described_class.new(stranger, pending).show?).to be false
    end
  end

  describe "#create?" do
    it "is true for any logged-in user" do
      expect(described_class.new(other_user, Comment.new(commentable: post_record)).create?).to be true
    end

    it "is true for guests when commentable allows guest comments" do
      post_record.update!(comments_enabled: true)
      expect(described_class.new(nil, Comment.new(commentable: post_record)).create?).to be true
    end

    it "is false for guests when commentable disallows guest comments" do
      post_record.update!(comments_enabled: false)
      expect(described_class.new(nil, Comment.new(commentable: post_record)).create?).to be false
    end
  end

  describe "#update?" do
    it "is true for the author when comment is pending" do
      pending = post_record.comments.create!(user: other_user, content: "x", status: "pending")
      expect(described_class.new(other_user, pending).update?).to be true
    end

    it "is false once the comment is approved" do
      expect(described_class.new(other_user, comment).update?).to be false
    end
  end

  describe "#destroy?" do
    it "is true for the comment author" do
      expect(described_class.new(other_user, comment).destroy?).to be true
    end

    it "is true for the content owner" do
      expect(described_class.new(author, comment).destroy?).to be true
    end

    it "is true for an admin" do
      expect(described_class.new(admin, comment).destroy?).to be true
    end

    it "is false for an unrelated user" do
      stranger = create(:user)
      expect(described_class.new(stranger, comment).destroy?).to be false
    end
  end

  describe "moderation actions" do
    it "approve/reject/mark_as_spam are allowed for the content owner" do
      p = described_class.new(author, comment)
      expect(p.approve?).to be true
      expect(p.reject?).to be true
      expect(p.mark_as_spam?).to be true
    end

    it "are forbidden for an unrelated user" do
      p = described_class.new(create(:user), comment)
      expect(p.approve?).to be false
      expect(p.reject?).to be false
      expect(p.mark_as_spam?).to be false
    end
  end

  describe "Scope" do
    let!(:approved) { post_record.comments.create!(user: other_user, content: "ok", status: "approved") }
    let!(:pending)  { post_record.comments.create!(user: other_user, content: "wait", status: "pending") }

    it "guests see only approved comments" do
      expect(CommentPolicy::Scope.new(nil, Comment).resolve).to contain_exactly(approved)
    end

    it "moderators see everything" do
      expect(CommentPolicy::Scope.new(moderator, Comment).resolve).to include(approved, pending)
    end

    it "logged-in users see approved + their own" do
      results = CommentPolicy::Scope.new(other_user, Comment).resolve
      expect(results).to include(approved, pending)
    end
  end
end
