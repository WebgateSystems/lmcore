# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive.allow_nil }
    it { is_expected.to validate_uniqueness_of(:phone).allow_nil }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending active suspended deleted]) }

    it 'validates email format' do
      user = build(:user, email: 'invalid')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end

    it 'validates username format' do
      user = build(:user, username: 'invalid user!')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to be_present
    end

    it 'validates username length' do
      user = build(:user, username: 'ab')
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:role).optional }
    it { is_expected.to belong_to(:price_plan).optional }
    it { is_expected.to have_many(:posts).dependent(:destroy) }
    it { is_expected.to have_many(:videos).dependent(:destroy) }
    it { is_expected.to have_many(:photos).dependent(:destroy) }
    it { is_expected.to have_many(:pages).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:nullify) }
    it { is_expected.to have_many(:reactions).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
    it { is_expected.to have_many(:following) }
    it { is_expected.to have_many(:followers) }
  end

  describe 'callbacks' do
    it 'normalizes email before save' do
      user = create(:user, email: '  USER@EXAMPLE.COM  ')
      expect(user.email).to eq('user@example.com')
    end

    it 'sets defaults on create' do
      user = User.new(email: 'test@example.com', password: 'password123')
      user.valid?
      expect(user.status).to eq('pending')
      expect(user.locale).to eq(I18n.default_locale.to_s)
      expect(user.timezone).to eq('UTC')
    end
  end

  describe 'status management' do
    let(:user) { create(:user, status: 'pending') }

    it 'activates user' do
      user.activate!
      expect(user.status).to eq('active')
    end

    it 'suspends user' do
      user.suspend!
      expect(user.status).to eq('suspended')
    end

    it 'soft deletes user' do
      user.soft_delete!
      expect(user.status).to eq('deleted')
      expect(user.discarded?).to be true
    end
  end

  describe 'role helpers' do
    it 'identifies super admin' do
      role = create(:role, slug: 'super-admin', permissions: [ '*' ], priority: 100, system_role: true)
      user = create(:user, role: role)
      expect(user.super_admin?).to be true
      expect(user.admin?).to be true
    end

    it 'identifies admin' do
      role = create(:role, slug: 'admin', permissions: %w[manage_users], priority: 90, system_role: true)
      user = create(:user, role: role)
      expect(user.super_admin?).to be false
      expect(user.admin?).to be true
    end

    it 'identifies author' do
      role = create(:role, slug: 'author', permissions: %w[create_content], priority: 30, system_role: true)
      user = create(:user, role: role)
      expect(user.author?).to be true
    end
  end

  describe '#full_name' do
    it 'returns first and last name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end

    it 'falls back to display_name' do
      user = build(:user, first_name: nil, last_name: nil, display_name: 'Johnny')
      expect(user.full_name).to eq('Johnny')
    end

    it 'falls back to username' do
      user = build(:user, first_name: nil, last_name: nil, display_name: nil, username: 'johnny')
      expect(user.full_name).to eq('johnny')
    end

    it 'falls back to email prefix' do
      user = build(:user, first_name: nil, last_name: nil, display_name: nil, username: nil, email: 'john@example.com')
      expect(user.full_name).to eq('john')
    end
  end

  describe 'following' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'follows another user' do
      user.follow(other_user)
      expect(user.following?(other_user)).to be true
      expect(other_user.followed_by?(user)).to be true
    end

    it 'unfollows a user' do
      user.follow(other_user)
      user.unfollow(other_user)
      expect(user.following?(other_user)).to be false
    end

    it 'does not create duplicate follows' do
      user.follow(other_user)
      expect { user.follow(other_user) }.not_to change { Follow.count }
    end
  end

  describe 'subscription helpers' do
    it 'checks if user can create post' do
      plan = create(:price_plan, posts_limit: 30, disk_space_mb: 100)
      user = create(:user, price_plan: plan)
      expect(user.can_create_post?).to be true
    end

    it 'prevents post creation when limit reached' do
      plan = create(:price_plan, posts_limit: 30, disk_space_mb: 100)
      user = create(:user, price_plan: plan, posts_this_month: 30)
      expect(user.can_create_post?).to be false
    end

    it 'calculates available disk space' do
      plan = create(:price_plan, posts_limit: 30, disk_space_mb: 100)
      user = create(:user, price_plan: plan, disk_space_used_bytes: 50 * 1024 * 1024)
      expect(user.disk_space_available).to eq(50 * 1024 * 1024)
    end

    it 'detects disk space exceeded' do
      plan = create(:price_plan, posts_limit: 30, disk_space_mb: 100)
      user = create(:user, price_plan: plan, disk_space_used_bytes: 150 * 1024 * 1024)
      expect(user.disk_space_exceeded?).to be true
    end
  end
end
