# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment do
  describe 'validations' do
    subject { build(:comment) }

    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_least(1).is_at_most(10_000) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending approved spam deleted]) }

    context 'when user is nil (guest comment)' do
      subject { build(:comment, :guest) }

      it { is_expected.to validate_presence_of(:guest_name) }
      it { is_expected.to validate_presence_of(:guest_email) }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:commentable) }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to belong_to(:approved_by).optional }
    it { is_expected.to have_many(:replies).dependent(:destroy) }
    it { is_expected.to have_many(:reactions) }
  end

  describe 'scopes' do
    let!(:pending_comment) { create(:comment, status: 'pending') }
    let!(:approved_comment) { create(:comment, :approved) }
    let!(:spam_comment) { create(:comment, :spam) }

    it 'filters approved comments' do
      expect(described_class.approved).to include(approved_comment)
      expect(described_class.approved).not_to include(pending_comment)
    end

    it 'filters pending comments' do
      expect(described_class.pending).to include(pending_comment)
      expect(described_class.pending).not_to include(approved_comment)
    end

    it 'filters spam comments' do
      expect(described_class.spam).to include(spam_comment)
    end
  end

  describe '#approve!' do
    let(:moderator) { create(:user) }
    let(:comment) { create(:comment) }

    it 'approves the comment' do
      comment.approve!(moderator)
      expect(comment.status).to eq('approved')
      expect(comment.approved_by).to eq(moderator)
      expect(comment.approved_at).to be_present
    end
  end

  describe '#mark_as_spam!' do
    it 'marks comment as spam' do
      comment = create(:comment)
      comment.mark_as_spam!
      expect(comment.status).to eq('spam')
    end
  end

  describe '#reject!' do
    it 'marks comment as deleted and discards it' do
      comment = create(:comment)
      comment.reject!
      expect(comment.status).to eq('deleted')
      expect(comment.discarded?).to be true
    end
  end

  describe '#author_name' do
    it 'returns user full name for registered user' do
      user = create(:user, first_name: 'John', last_name: 'Doe')
      comment = build(:comment, user: user)
      expect(comment.author_name).to eq('John Doe')
    end

    it 'returns guest_name for guest comment' do
      comment = build(:comment, :guest, guest_name: 'Guest User')
      expect(comment.author_name).to eq('Guest User')
    end
  end

  describe '#reply?' do
    it 'returns true if comment has a parent' do
      parent = create(:comment)
      reply = create(:comment, parent: parent, commentable: parent.commentable)
      expect(reply.reply?).to be true
    end

    it 'returns false if comment is root' do
      comment = create(:comment)
      expect(comment.reply?).to be false
    end
  end

  describe '#depth' do
    it 'returns 0 for root comments' do
      comment = create(:comment)
      expect(comment.depth).to eq(0)
    end

    it 'returns 1 for first-level replies' do
      parent = create(:comment)
      reply = create(:comment, parent: parent, commentable: parent.commentable)
      expect(reply.depth).to eq(1)
    end

    it 'returns correct depth for nested replies' do
      root = create(:comment)
      level1 = create(:comment, parent: root, commentable: root.commentable)
      level2 = create(:comment, parent: level1, commentable: root.commentable)
      expect(level2.depth).to eq(2)
    end
  end

  describe '#reply_to' do
    let(:user) { create(:user) }
    let(:comment) { create(:comment) }

    it 'creates a reply' do
      reply = comment.reply_to(content: 'Reply content', user: user)
      expect(reply).to be_persisted
      expect(reply.parent).to eq(comment)
      expect(reply.commentable).to eq(comment.commentable)
    end
  end

  describe 'parent validation' do
    it 'validates parent belongs to same commentable' do
      post1 = create(:post)
      post2 = create(:post)
      parent = create(:comment, commentable: post1)
      comment = build(:comment, parent: parent, commentable: post2)

      expect(comment).not_to be_valid
      expect(comment.errors[:parent]).to be_present
    end
  end

  it_behaves_like 'reactable'
end
