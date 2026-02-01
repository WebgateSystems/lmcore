# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post do
  describe 'validations' do
    subject { build(:post) }

    it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:author_id) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[draft pending scheduled published archived]) }

    it 'validates title presence for at least one locale' do
      post = build(:post, title_i18n: {})
      expect(post).not_to be_valid
      expect(post.errors[:title_i18n]).to be_present
    end

    it 'validates content presence for at least one locale' do
      post = build(:post, content_i18n: {})
      expect(post).not_to be_valid
      expect(post.errors[:content_i18n]).to be_present
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:category).optional }
    it { is_expected.to belong_to(:published_by).class_name('User').optional }
    it { is_expected.to have_many(:media_attachments) }
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:tags) }
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:reactions) }
  end

  describe 'scopes' do
    it 'filters draft posts' do
      draft = create(:post, status: 'draft')
      published = create(:post, status: 'published', published_at: Time.current)
      expect(described_class.draft).to include(draft)
      expect(described_class.draft).not_to include(published)
    end

    it 'filters published posts' do
      draft = create(:post, status: 'draft')
      published = create(:post, status: 'published', published_at: Time.current)
      expect(described_class.published).to include(published)
      expect(described_class.published).not_to include(draft)
    end

    it 'filters featured posts' do
      published = create(:post, status: 'published', published_at: Time.current, featured: false)
      featured = create(:post, status: 'published', published_at: Time.current, featured: true)
      expect(described_class.featured).to include(featured)
      expect(described_class.featured).not_to include(published)
    end

    it 'filters visible posts' do
      draft = create(:post, status: 'draft')
      published = create(:post, status: 'published', published_at: Time.current)
      expect(described_class.visible).to include(published)
      expect(described_class.visible).not_to include(draft)
    end
  end

  describe '#reading_time' do
    it 'calculates reading time based on content' do
      post = build(:post, content_i18n: { 'en' => 'word ' * 400 })
      expect(post.reading_time).to eq(2)
    end

    it 'returns at least 1 minute' do
      post = build(:post, content_i18n: { 'en' => 'short' })
      expect(post.reading_time).to eq(1)
    end
  end

  describe '#increment_views!' do
    it 'increments views count' do
      post = create(:post)
      expect { post.increment_views! }.to change { post.reload.views_count }.by(1)
    end
  end

  describe '#related_posts' do
    it 'returns posts with common tags' do
      tag = create(:tag)
      post1 = create(:post, status: 'published', published_at: Time.current)
      post2 = create(:post, status: 'published', published_at: Time.current)
      post1.tags << tag
      post2.tags << tag

      expect(post1.related_posts).to include(post2)
    end

    it 'does not include self' do
      post = create(:post, status: 'published', published_at: Time.current)
      tag = create(:tag)
      post.tags << tag
      expect(post.related_posts).not_to include(post)
    end
  end

  it_behaves_like 'sluggable'
  it_behaves_like 'publishable'
  it_behaves_like 'taggable'
  it_behaves_like 'reactable'
  it_behaves_like 'commentable'
  it_behaves_like 'translatable', :title, :subtitle, :lead, :content
end
