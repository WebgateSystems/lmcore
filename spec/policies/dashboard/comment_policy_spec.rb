# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::CommentPolicy, type: :policy do
  subject(:policy) { described_class.new(user, record) }

  let(:author) { create(:user, :author) }
  let(:other_author) { create(:user, :author) }
  let(:moderator) { create(:user, :moderator) }
  let(:visitor) { create(:user) }
  let(:my_post) { create(:post, author: author) }
  let(:other_post) { create(:post, author: other_author) }
  let(:my_comment) { create(:comment, commentable: my_post) }
  let(:foreign_comment) { create(:comment, commentable: other_post) }

  describe "#index?" do
    it "is permitted for any dashboard user" do
      expect(described_class.new(author, Comment).index?).to be true
      expect(described_class.new(moderator, Comment).index?).to be true
    end

    it "is not permitted for users without dashboard role" do
      expect(described_class.new(visitor, Comment).index?).to be false
    end
  end

  context "with a comment on the user's own content" do
    let(:user) { author }
    let(:record) { my_comment }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "with a comment on someone else's content" do
    let(:record) { foreign_comment }

    it "is not permitted for the author of unrelated content" do
      policy_for_other = described_class.new(author, foreign_comment)
      expect(policy_for_other.show?).to be false
      expect(policy_for_other.update?).to be false
      expect(policy_for_other.destroy?).to be false
    end

    # Moderators do NOT get cross-blog access on /dashboard. Use /admin
    # for platform-wide comment moderation.
    it "is not permitted for moderators either" do
      policy_for_mod = described_class.new(moderator, foreign_comment)
      expect(policy_for_mod.show?).to be false
      expect(policy_for_mod.update?).to be false
      expect(policy_for_mod.destroy?).to be false
    end
  end

  describe Dashboard::CommentPolicy::Scope do
    it "returns only comments on the user's own commentables" do
      mine = create(:comment, commentable: my_post)
      create(:comment, commentable: other_post)

      scope = described_class.new(author, Comment.all).resolve
      expect(scope).to contain_exactly(mine)
    end

    it "limits moderators to comments on their own content too" do
      moderator_post = create(:post, author: moderator)
      mod_comment = create(:comment, commentable: moderator_post)
      create(:comment, commentable: my_post)
      create(:comment, commentable: other_post)

      scope = described_class.new(moderator, Comment.all).resolve
      expect(scope).to contain_exactly(mod_comment)
    end

    it "returns nothing for users without a dashboard role" do
      create(:comment, commentable: my_post)
      scope = described_class.new(visitor, Comment.all).resolve
      expect(scope).to be_empty
    end
  end
end
