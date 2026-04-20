# frozen_string_literal: true

require "rails_helper"

# Exercises the shared private helpers (`owner?`, `record_owner`,
# `can_edit?`, `can_moderate?`) that every policy inherits. We use Post as a
# representative record because it responds to both `author` and
# `author_id`, which is what most concrete policies inherit.
RSpec.describe ApplicationPolicy, type: :policy do
  let(:user)   { create(:user) }
  let(:author) { create(:user) }
  let(:admin)  { create(:user, :admin) }
  let(:record) { create(:post, author: author) }

  describe "default actions" do
    it "index? and show? are open by default" do
      p = described_class.new(nil, record)
      expect(p.index?).to be true
      expect(p.show?).to be true
    end

    it "create? requires a logged-in user" do
      expect(described_class.new(nil, record).create?).to be false
      expect(described_class.new(user, record).create?).to be true
    end

    it "update? is true for the owner or an admin" do
      expect(described_class.new(author, record).update?).to be true
      expect(described_class.new(admin, record).update?).to be true
      expect(described_class.new(user, record).update?).to be false
    end

    it "destroy? is true for the owner or an admin" do
      expect(described_class.new(author, record).destroy?).to be true
      expect(described_class.new(admin, record).destroy?).to be true
      expect(described_class.new(user, record).destroy?).to be false
    end

    it "edit? aliases update?" do
      p = described_class.new(author, record)
      expect(p.edit?).to eq(p.update?)
    end

    it "new? aliases create?" do
      p = described_class.new(user, record)
      expect(p.new?).to eq(p.create?)
    end
  end

  describe "owner? helper (via update?)" do
    it "matches by author_id" do
      expect(described_class.new(author, record).update?).to be true
    end

    it "matches by user_id when the record uses :user" do
      reaction_owner = create(:user)
      reaction = record.reactions.create!(user: reaction_owner, reaction_type: "like")
      # Reaction has `user_id`, so owner? should fall through to that branch.
      expect(described_class.new(reaction_owner, reaction).update?).to be true
      expect(described_class.new(create(:user), reaction).update?).to be false
    end

    it "matches a User record against itself" do
      expect(described_class.new(user, user).update?).to be true
    end
  end

  describe "Scope abstract base" do
    it "raises when #resolve is not overridden" do
      expect {
        ApplicationPolicy::Scope.new(user, Post).resolve
      }.to raise_error(NotImplementedError)
    end
  end

  describe "contextual role helpers" do
    let(:author) { create(:user, :author) }
    let(:moderator) { create(:user) }
    let(:editor)    { create(:user) }
    let(:other)     { create(:user) }
    let(:record)    { create(:post, author: author) }

    before do
      Role.find_by(slug: "moderator") || create(:role, slug: "moderator", name: "Moderator")
      Role.find_by(slug: "editor") || create(:role, slug: "editor", name: "Editor")
      moderator.assign_role!("moderator", scope: author, granted_by: author)
      editor.assign_role!("editor", scope: author, granted_by: author)
    end

    it "can_moderate? is true for moderators (and admins) on that author's blog" do
      expect(described_class.new(moderator, record).send(:can_moderate?)).to be true
      expect(described_class.new(create(:user, :admin), record).send(:can_moderate?)).to be true
      expect(described_class.new(other, record).send(:can_moderate?)).to be false
      expect(described_class.new(nil, record).send(:can_moderate?)).to be false
    end

    it "can_edit? is true for editors and admins" do
      expect(described_class.new(editor, record).send(:can_edit?)).to be true
      expect(described_class.new(create(:user, :admin), record).send(:can_edit?)).to be true
      expect(described_class.new(other, record).send(:can_edit?)).to be false
    end

    it "can_author? returns true for admins regardless of context" do
      expect(described_class.new(create(:user, :admin), record).send(:can_author?)).to be true
    end

    it "super_admin? checks the user's flag" do
      sa = create(:user, :super_admin)
      expect(described_class.new(sa, record).send(:super_admin?)).to be true
      expect(described_class.new(other, record).send(:super_admin?)).to be false
    end
  end

  describe "#record_owner fallbacks" do
    it "returns the record itself when it's a User" do
      u = create(:user)
      expect(described_class.new(u, u).send(:record_owner)).to eq(u)
    end

    it "returns nil when no record is given" do
      expect(described_class.new(create(:user), nil).send(:record_owner)).to be_nil
    end

    it "uses :user when the record responds to :user but not :author" do
      reaction_owner = create(:user)
      post = create(:post, author: create(:user, :author))
      reaction = post.reactions.create!(user: reaction_owner, reaction_type: "like")
      # Reaction responds to :user but not :author -- record_owner picks :user.
      policy = described_class.new(reaction_owner, reaction)
      expect(policy.send(:record_owner)).to eq(reaction_owner)
    end
  end
end
