# frozen_string_literal: true

require "rails_helper"

RSpec.describe Commentable do
  let(:author) { create(:user, :author) }
  let(:post_record) { create(:post, author: author) }

  describe "comment scopes and helpers on commentable models" do
    let!(:approved_root) { create(:comment, :approved, commentable: post_record) }
    let!(:pending_root) { create(:comment, status: "pending", commentable: post_record) }
    let!(:approved_reply) { create(:comment, :approved, commentable: post_record, parent: approved_root) }

    it "returns root, approved and pending comments" do
      expect(post_record.root_comments).to contain_exactly(approved_root, pending_root)
      expect(post_record.approved_comments).to contain_exactly(approved_root, approved_reply)
      expect(post_record.pending_comments).to contain_exactly(pending_root)
    end

    it "builds comments tree from approved root comments with eager loading" do
      tree = post_record.comments_tree
      expect(tree).to contain_exactly(approved_root)
      expect(tree.first.association(:replies)).to be_loaded
    end

    it "adds comment with request metadata from Current attributes" do
      Current.ip_address = "127.0.0.1"
      Current.user_agent = "RSpec UA"
      comment = post_record.add_comment(content: "new comment", user: author)

      expect(comment.ip_address).to eq("127.0.0.1")
      expect(comment.user_agent).to eq("RSpec UA")
      expect(comment.content).to eq("new comment")
    end

    it "updates cached comments_count with approved comments only" do
      post_record.send(:update_comments_count)
      expect(post_record.reload.comments_count).to eq(post_record.comments.approved.count)
    end
  end
end
