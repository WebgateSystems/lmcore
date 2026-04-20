# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContentVisibility, type: :model do
  let(:author) { create(:user, :author) }
  let(:viewer) { create(:user) }
  let(:post)   { create(:post, :published, author: author) }

  describe "validations" do
    it "requires a known access_level" do
      cv = described_class.new(visible: post, target: viewer, access_level: "wat")
      expect(cv).not_to be_valid
      expect(cv.errors[:access_level]).to be_present
    end

    it "is unique per (visible, target, target_type)" do
      described_class.create!(visible: post, target: viewer, access_level: "read")
      dup = described_class.new(visible: post, target: viewer, access_level: "comment")
      expect(dup).not_to be_valid
    end
  end

  describe "scopes" do
    let!(:read_cv)    { described_class.create!(visible: post, target: viewer, access_level: "read") }
    let!(:comment_cv) { described_class.create!(visible: post, target: create(:user), access_level: "comment") }
    let!(:hidden_cv)  { described_class.create!(visible: post, target: create(:user), access_level: "hidden") }

    it ".readable returns read+comment" do
      expect(described_class.readable).to contain_exactly(read_cv, comment_cv)
    end

    it ".commentable returns only comment-level" do
      expect(described_class.commentable).to contain_exactly(comment_cv)
    end

    it ".hidden returns only hidden-level" do
      expect(described_class.hidden).to contain_exactly(hidden_cv)
    end

    it ".for_users / .for_groups partition by target_type" do
      group = create(:user_group, owner: author)
      group_cv = described_class.create!(visible: post, target: group, access_level: "read")
      expect(described_class.for_groups).to contain_exactly(group_cv)
      expect(described_class.for_users).to include(read_cv, comment_cv, hidden_cv)
    end

    it ".for_content filters by visible record" do
      other_post = create(:post, :published, author: author)
      expect(described_class.for_content(other_post)).to be_empty
      expect(described_class.for_content(post)).to include(read_cv)
    end
  end

  describe "instance predicates" do
    it "#readable? is true for read and comment" do
      expect(described_class.new(access_level: "read")).to be_readable
      expect(described_class.new(access_level: "comment")).to be_readable
      expect(described_class.new(access_level: "hidden")).not_to be_readable
    end

    it "#commentable? / #hidden?" do
      expect(described_class.new(access_level: "comment")).to be_commentable
      expect(described_class.new(access_level: "hidden")).to be_hidden
    end

    it "#user_target? / #group_target?" do
      expect(described_class.new(target_type: "User")).to be_user_target
      expect(described_class.new(target_type: "UserGroup")).to be_group_target
    end
  end

  describe ".grant_access / .revoke_access" do
    it "creates a record with the requested level" do
      cv = described_class.grant_access(post, viewer, level: "comment")
      expect(cv).to be_persisted
      expect(cv.access_level).to eq("comment")
    end

    it "is idempotent (find_or_create)" do
      first = described_class.grant_access(post, viewer)
      second = described_class.grant_access(post, viewer, level: "comment") # level ignored on existing record
      expect(second.id).to eq(first.id)
    end

    it ".revoke_access removes the record" do
      described_class.grant_access(post, viewer)
      expect { described_class.revoke_access(post, viewer) }
        .to change { described_class.count }.by(-1)
    end

    it ".revoke_access is a no-op when nothing exists" do
      expect { described_class.revoke_access(post, viewer) }.not_to raise_error
    end
  end

  describe ".can_access?" do
    it "is true when no visibility rules exist (post is public)" do
      expect(described_class.can_access?(post, viewer)).to be true
    end

    it "is false for a guest when at least one rule exists" do
      described_class.grant_access(post, author)
      expect(described_class.can_access?(post, nil)).to be false
    end

    it "is true for users explicitly granted read access" do
      described_class.grant_access(post, viewer, level: "read")
      expect(described_class.can_access?(post, viewer)).to be true
    end

    it "is true via group membership" do
      group = create(:user_group, owner: author)
      group.add_member(viewer)
      described_class.grant_access(post, group, level: "read")
      expect(described_class.can_access?(post, viewer)).to be true
    end

    it "is false for hidden access level" do
      described_class.grant_access(post, viewer, level: "hidden")
      expect(described_class.can_access?(post, viewer)).to be false
    end
  end

  describe ".can_comment?" do
    it "is false for guests" do
      expect(described_class.can_comment?(post, nil)).to be false
    end

    it "is true when the user has been given comment-level access directly" do
      described_class.grant_access(post, viewer, level: "comment")
      expect(described_class.can_comment?(post, viewer)).to be true
    end

    it "is false when the user only has read-level access" do
      described_class.grant_access(post, viewer, level: "read")
      expect(described_class.can_comment?(post, viewer)).to be false
    end

    it "is true via a group with comment-level access" do
      group = create(:user_group, owner: author)
      group.add_member(viewer)
      described_class.grant_access(post, group, level: "comment")
      expect(described_class.can_comment?(post, viewer)).to be true
    end
  end
end
