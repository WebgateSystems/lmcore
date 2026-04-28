# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BlogContactMessages", type: :request do
  let!(:blog_owner) { create(:user, username: "owner_contact") }
  let!(:sender) { create(:user, email: "sender@example.com") }

  describe "POST /blogs/:blog_slug/contact_messages" do
    it "requires authentication" do
      post blog_contact_messages_path(blog_slug: blog_owner.username), params: {
        contact_message: { message: "Please contact me back." }
      }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a contact message for signed-in user and fills missing identity fields" do
      sign_in sender

      expect do
        post blog_contact_messages_path(blog_slug: blog_owner.username), params: {
          contact_message: {
            name: "",
            email: "",
            message: "Please contact me back."
          },
          return_to: "/blogs/#{blog_owner.username}/pages/about"
        }
      end.to change(ContactMessage, :count).by(1)

      expect(response).to redirect_to("/blogs/#{blog_owner.username}/pages/about")
      message = ContactMessage.order(:created_at).last
      expect(message.user).to eq(sender)
      expect(message.blog_owner).to eq(blog_owner)
      expect(message.name).to eq(sender.full_name)
      expect(message.email).to eq(sender.email)
    end

    it "blocks banned users from sending messages" do
      sign_in sender
      create(:blog_ban, blog_owner: blog_owner, user: sender, banned_by: blog_owner, active: true, permanent: true)

      expect do
        post blog_contact_messages_path(blog_slug: blog_owner.username), params: {
          contact_message: { message: "Blocked message body." }
        }
      end.not_to change(ContactMessage, :count)

      expect(response).to redirect_to(blog_path(blog_slug: blog_owner.username))
      expect(flash[:blog_alert]).to be_present
    end
  end
end
