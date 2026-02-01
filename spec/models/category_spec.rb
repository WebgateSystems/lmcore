# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category do
  describe 'validations' do
    subject { build(:category) }

    it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:user_id) }
    it { is_expected.to validate_inclusion_of(:category_type).in_array(%w[general posts videos photos]) }
    it { is_expected.to validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }

    it 'validates parent cannot be self' do
      user = create(:user)
      category = create(:category, user: user)
      category.parent = category
      expect(category).not_to be_valid
      expect(category.errors[:parent_id]).to be_present
    end

    it 'validates parent must belong to same user' do
      user1 = create(:user)
      user2 = create(:user)
      parent = create(:category, user: user1)
      category = build(:category, user: user2, parent: parent)

      expect(category).not_to be_valid
      expect(category.errors[:parent_id]).to be_present
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:parent).optional }
    it { is_expected.to have_many(:children) }
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:videos) }
    it { is_expected.to have_many(:photos) }
  end

  describe 'scopes' do
    it 'filters root categories' do
      user = create(:user)
      root = create(:category, user: user)
      child = create(:category, user: user, parent: root)

      expect(described_class.roots).to include(root)
      expect(described_class.roots).not_to include(child)
    end
  end

  describe 'hierarchy' do
    describe '#root?' do
      it 'returns true for root categories' do
        user = create(:user)
        root = create(:category, user: user)
        expect(root.root?).to be true
      end

      it 'returns false for child categories' do
        user = create(:user)
        root = create(:category, user: user)
        child = create(:category, user: user, parent: root)
        expect(child.root?).to be false
      end
    end

    describe '#leaf?' do
      it 'returns true for categories without children' do
        user = create(:user)
        root = create(:category, user: user)
        child = create(:category, user: user, parent: root)
        grandchild = create(:category, user: user, parent: child)
        expect(grandchild.leaf?).to be true
      end

      it 'returns false for categories with children' do
        user = create(:user)
        root = create(:category, user: user)
        create(:category, user: user, parent: root)
        expect(root.reload.leaf?).to be false
      end
    end

    describe '#ancestors' do
      it 'returns empty array for root' do
        user = create(:user)
        root = create(:category, user: user)
        expect(root.ancestors).to eq([])
      end

      it 'returns ancestors in order' do
        user = create(:user)
        root = create(:category, user: user)
        child = create(:category, user: user, parent: root)
        grandchild = create(:category, user: user, parent: child)
        expect(grandchild.ancestors).to eq([ root, child ])
      end
    end

    describe '#descendants' do
      it 'returns all descendants' do
        user = create(:user)
        root = create(:category, user: user)
        child = create(:category, user: user, parent: root)
        grandchild = create(:category, user: user, parent: child)
        expect(root.descendants).to include(child, grandchild)
      end
    end

    describe '#depth' do
      it 'returns 0 for root' do
        user = create(:user)
        root = create(:category, user: user)
        expect(root.depth).to eq(0)
      end

      it 'returns correct depth for nested categories' do
        user = create(:user)
        root = create(:category, user: user)
        child = create(:category, user: user, parent: root)
        grandchild = create(:category, user: user, parent: child)
        expect(grandchild.depth).to eq(2)
      end
    end
  end

  describe '#content_count' do
    it 'sums all content counters' do
      category = build(:category, posts_count: 5, videos_count: 3, photos_count: 2)
      expect(category.content_count).to eq(10)
    end
  end

  it_behaves_like 'sluggable'
  it_behaves_like 'translatable', :name, :description
end
