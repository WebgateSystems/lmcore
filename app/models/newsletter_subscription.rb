# frozen_string_literal: true

class NewsletterSubscription < ApplicationRecord
  belongs_to :blog_owner, class_name: "User", inverse_of: :newsletter_subscriptions_received
  belongs_to :user, inverse_of: :newsletter_subscriptions

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :blog_owner_id, case_sensitive: false }
end
