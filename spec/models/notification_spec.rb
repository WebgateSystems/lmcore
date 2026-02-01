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
  end
end
