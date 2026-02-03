# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role do
  describe 'validations' do
    subject { create(:role) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_numericality_of(:priority).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:role_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:role_assignments) }
  end

  describe 'scopes' do
    it 'filters system roles' do
      system_role = create(:role, system_role: true)
      custom_role = create(:role, system_role: false)
      expect(described_class.system_roles).to include(system_role)
      expect(described_class.system_roles).not_to include(custom_role)
    end

    it 'filters custom roles' do
      system_role = create(:role, system_role: true)
      custom_role = create(:role, system_role: false)
      expect(described_class.custom_roles).to include(custom_role)
      expect(described_class.custom_roles).not_to include(system_role)
    end

    it 'orders by priority' do
      create(:role, priority: 10)
      high = create(:role, priority: 90)
      expect(described_class.ordered.first).to eq(high)
    end
  end

  describe '#has_permission?' do
    it 'returns true if permission exists' do
      role = build(:role, permissions: [ 'manage_users' ])
      expect(role.has_permission?('manage_users')).to be true
    end

    it 'returns false if permission does not exist' do
      role = build(:role, permissions: [ 'manage_users' ])
      expect(role.has_permission?('manage_content')).to be false
    end

    it 'returns true for wildcard permission' do
      role = build(:role, permissions: [ '*' ])
      expect(role.has_permission?('anything')).to be true
    end
  end

  describe '#add_permission' do
    it 'adds a new permission' do
      role = build(:role, permissions: [])
      role.add_permission('new_permission')
      expect(role.permissions).to include('new_permission')
    end

    it 'does not duplicate permissions' do
      role = build(:role, permissions: [ 'existing' ])
      role.add_permission('existing')
      expect(role.permissions.count('existing')).to eq(1)
    end
  end

  describe '#remove_permission' do
    it 'removes an existing permission' do
      role = build(:role, permissions: %w[one two])
      role.remove_permission('one')
      expect(role.permissions).not_to include('one')
      expect(role.permissions).to include('two')
    end
  end

  it_behaves_like 'sluggable'
  it_behaves_like 'translatable', :name, :description
end
