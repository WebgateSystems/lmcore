# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification do
  describe 'validations' do
    subject { build(:notification) }

    it { is_expected.to validate_presence_of(:notification_type) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:actor).optional }
    it { is_expected.to belong_to(:notifiable).optional }
  end

  describe 'scopes' do
    let!(:unread) { create(:notification) }
    let!(:read) { create(:notification, :read) }

    it 'filters unread notifications' do
      expect(described_class.unread).to include(unread)
      expect(described_class.unread).not_to include(read)
    end

    it 'filters read notifications' do
      expect(described_class.read).to include(read)
      expect(described_class.read).not_to include(unread)
    end
  end

  describe '.mark_all_as_read!' do
    it 'marks all user notifications as read' do
      user = create(:user)
      notifications = create_list(:notification, 3, user: user)

      described_class.mark_all_as_read!(user)

      notifications.each do |notification|
        expect(notification.reload.read_at).to be_present
      end
    end
  end

  describe '.unread_count' do
    it 'returns count of unread notifications' do
      user = create(:user)
      create_list(:notification, 3, user: user)
      create(:notification, :read, user: user)

      expect(described_class.unread_count(user)).to eq(3)
    end
  end

  describe '#read!' do
    it 'marks notification as read' do
      notification = create(:notification)
      notification.read!
      expect(notification.read?).to be true
    end

    it 'does not update if already read' do
      notification = create(:notification, :read)
      original_read_at = notification.read_at
      notification.read!
      expect(notification.read_at).to eq(original_read_at)
    end
  end

  describe '#mark_as_sent!' do
    it 'marks notification as sent' do
      notification = create(:notification)
      notification.mark_as_sent!('email')

      expect(notification.sent?).to be true
      expect(notification.delivery_method).to eq('email')
    end
  end

  describe '#icon' do
    it 'returns appropriate icon for notification type' do
      expect(build(:notification, notification_type: 'new_comment').icon).to eq('comment')
      expect(build(:notification, notification_type: 'new_follower').icon).to eq('user-plus')
      expect(build(:notification, notification_type: 'new_donation').icon).to eq('heart')
      expect(build(:notification, notification_type: 'system').icon).to eq('bell')
    end

    it 'returns the right icon for less-common types' do
      expect(build(:notification, notification_type: 'comment_reply').icon).to eq('comment')
      expect(build(:notification, notification_type: 'post_published').icon).to eq('file-text')
      expect(build(:notification, notification_type: 'post_featured').icon).to eq('file-text')
      expect(build(:notification, notification_type: 'mention').icon).to eq('at-sign')
      expect(build(:notification, notification_type: 'subscription_expiring').icon).to eq('alert-circle')
      expect(build(:notification, notification_type: 'subscription_expired').icon).to eq('alert-circle')
      expect(build(:notification, notification_type: 'payment_received').icon).to eq('credit-card')
      expect(build(:notification, notification_type: 'payment_failed').icon).to eq('credit-card')
    end
  end

  describe '#unsent / .unsent scope' do
    it 'lists only notifications without sent_at' do
      sent = create(:notification, sent_at: Time.current, delivery_method: 'email')
      pending_send = create(:notification)
      expect(described_class.unsent).to contain_exactly(pending_send)
      expect(sent).to be_sent
      expect(pending_send).not_to be_sent
    end
  end

  describe '#unread?' do
    it 'is the inverse of #read?' do
      expect(build(:notification)).to be_unread
      expect(build(:notification, :read)).not_to be_unread
    end
  end

  describe '.create_notification' do
    it 'creates a record with the supplied attributes' do
      user = create(:user)
      actor = create(:user)
      n = described_class.create_notification(user: user, actor: actor, type: 'welcome', data: { foo: 'bar' })
      expect(n).to be_persisted
      expect(n.actor).to eq(actor)
      expect(n.user).to eq(user)
      expect(n.notification_type).to eq('welcome')
      expect(n.data).to eq({ 'foo' => 'bar' })
    end
  end

  describe '#title / #message' do
    it 'falls back to a humanised default when no translation key matches' do
      n = build(:notification, notification_type: 'system', data: {})
      expect(n.title).to eq('System')
      expect(n.message).to eq('')
    end
  end

  describe '#url' do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }

    it 'is nil for types without a destination' do
      n = build(:notification, notification_type: 'system', notifiable: nil)
      expect(n.url).to be_nil
    end

    it 'returns the actor profile path for new_follower' do
      n = build(:notification, notification_type: 'new_follower', user: user, actor: actor)
      expect(n.url).to eq("/@#{actor.username}")
    end

    it 'returns the post path for post_published' do
      post = create(:post, :published, author: user)
      n = build(:notification, notification_type: 'post_published', user: user, notifiable: post)
      expect(n.url).to eq("/posts/#{post.slug}")
    end
  end
end
