# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyCommentAuthorWorker, type: :worker do
  let(:author)     { create(:user, :author) }
  let(:commenter)  { create(:user) }
  let(:post)       { create(:post, :published, author: author) }
  let(:comment)    { post.comments.create!(user: commenter, content: "hi", status: "approved") }

  it "is a no-op when the comment id no longer exists" do
    expect {
      described_class.new.perform(0)
    }.not_to change { Notification.count }
  end

  it "is a no-op when the commenter IS the content author (no self-notify)" do
    self_comment = post.comments.create!(user: author, content: "self", status: "approved")
    expect {
      described_class.new.perform(self_comment.id)
    }.not_to change { Notification.count }
  end

  it "creates a new_comment notification for the content author" do
    expect {
      described_class.new.perform(comment.id)
    }.to change { Notification.where(notification_type: "new_comment").count }.by(1)

    notif = Notification.where(notification_type: "new_comment").last
    expect(notif.user).to eq(author)
    expect(notif.actor).to eq(commenter)
    expect(notif.notifiable).to eq(comment)
    expect(notif.data).to include("content_type" => "Post")
  end

  it "additionally pings the parent comment author for replies" do
    parent_user = create(:user)
    parent_comment = post.comments.create!(user: parent_user, content: "first", status: "approved")
    reply = post.comments.create!(user: commenter, content: "re", status: "approved", parent: parent_comment)

    expect {
      described_class.new.perform(reply.id)
    }.to change { Notification.count }.by(2)

    expect(Notification.where(notification_type: "comment_reply", user: parent_user)).to exist
  end

  it "re-raises (and logs) underlying errors" do
    allow(Comment).to receive(:find_by).and_raise(StandardError, "boom")
    expect(Rails.logger).to receive(:error).with(/boom/)
    expect { described_class.new.perform(comment.id) }.to raise_error(StandardError)
  end
end
