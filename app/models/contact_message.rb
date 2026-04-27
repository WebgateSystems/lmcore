# frozen_string_literal: true

class ContactMessage < ApplicationRecord
  belongs_to :blog_owner, class_name: "User", inverse_of: :contact_messages_received
  belongs_to :user, inverse_of: :contact_messages_sent

  validates :name, presence: true, length: { maximum: 120 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { minimum: 6, maximum: 5000 }
end
