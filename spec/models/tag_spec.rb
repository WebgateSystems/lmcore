# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag do
  describe 'validations' do
    subject { build(:tag) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:videos) }
    it { is_expected.to have_many(:photos) }
  end

  describe 'callbacks' do
    it 'normalizes name before validation' do
      tag = create(:tag, name: '  Ruby on Rails  ')
      expect(tag.name).to eq('ruby on rails')
    end
  end

  describe 'scopes' do
    it 'orders by popularity' do
      create(:tag, taggings_count: 5)
      more_popular = create(:tag, taggings_count: 10)

      expect(described_class.popular.first).to eq(more_popular)
    end

    it 'orders alphabetically' do
      create(:tag, name: 'zebra')
      alpha = create(:tag, name: 'alpha')

      expect(described_class.alphabetical.first).to eq(alpha)
    end

    it 'filters tags with content' do
      with_content = create(:tag, taggings_count: 1)
      without_content = create(:tag, taggings_count: 0)

      expect(described_class.with_content).to include(with_content)
      expect(described_class.with_content).not_to include(without_content)
    end
  end

  describe '.find_or_create_by_name' do
    it 'creates a new tag' do
      expect { described_class.find_or_create_by_name('new-tag') }.to change(described_class, :count).by(1)
    end

    it 'returns existing tag' do
      existing = create(:tag, name: 'existing')
      result = described_class.find_or_create_by_name('existing')
      expect(result).to eq(existing)
    end

    it 'normalizes and strips the name' do
      tag = described_class.find_or_create_by_name('  New Tag  ')
      expect(tag.name).to eq('new tag')
    end
  end

  describe '.search' do
    let!(:ruby) { create(:tag, name: 'ruby') }
    let!(:ruby_on_rails) { create(:tag, name: 'ruby on rails') }
    let!(:python) { create(:tag, name: 'python') }

    it 'finds tags by partial name' do
      results = described_class.search('ruby')
      expect(results).to include(ruby, ruby_on_rails)
      expect(results).not_to include(python)
    end
  end

  describe '#merge_into' do
    it 'moves all taggings to target tag' do
      source = create(:tag)
      target = create(:tag)
      post = create(:post)
      post.tags << source

      source.merge_into(target)

      expect(post.reload.tags).to include(target)
      expect(post.tags).not_to include(source)
      expect { source.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns false when merging into self' do
      tag = create(:tag)
      expect(tag.merge_into(tag)).to be false
    end
  end

  it_behaves_like 'sluggable'
end
