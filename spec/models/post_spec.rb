# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post do
  describe 'validations' do
    subject { build(:post) }

    it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:author_id) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[draft pending scheduled published archived]) }
    it { is_expected.to validate_inclusion_of(:content_format).in_array(%w[html markdown]) }

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

    it 'rejects an unknown content_format value' do
      post = build(:post, content_format: 'doc')
      expect(post).not_to be_valid
      expect(post.errors[:content_format]).to be_present
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

  describe 'content rendering callback' do
    let(:author) { create(:user, :author) }

    it 'rerenders content_i18n on save when content_source_i18n changes' do
      post = create(:post, author: author, content_format: 'html',
                           content_source_i18n: { 'en' => '<p>Initial</p>' })
      expect(post.content_i18n['en']).to include('<p>Initial</p>')

      post.update!(content_source_i18n: { 'en' => '<p>Updated</p>' })
      expect(post.content_i18n['en']).to include('<p>Updated</p>')
    end

    it 'rerenders when content_format flips from html to markdown' do
      post = create(:post, author: author, content_format: 'html',
                           content_source_i18n: { 'en' => '# H1' })
      expect(post.content_i18n['en']).to include('# H1') # raw, was treated as html

      post.update!(content_format: 'markdown')
      expect(post.content_i18n['en']).to include('<h1>H1</h1>')
    end

    it 'does not run the renderer when only unrelated attributes change' do
      post = create(:post, author: author, content_format: 'html',
                           content_source_i18n: { 'en' => '<p>x</p>' })
      expect(Posts::ContentRenderer).not_to receive(:render)
      post.update!(views_count: post.views_count + 1)
    end
  end

  describe '#inline_images' do
    let(:author) { create(:user, :author) }
    let(:post)   { create(:post, author: author) }

    it 'returns only image attachments ordered by position' do
      doc   = create(:media_attachment, :document, user: author, attachable: post, position: 1)
      img_b = create(:media_attachment,            user: author, attachable: post, position: 5)
      img_a = create(:media_attachment,            user: author, attachable: post, position: 1)

      expect(post.inline_images.to_a).to eq([ img_a, img_b ])
      expect(post.inline_images).not_to include(doc)
    end
  end

  describe '#documents' do
    let(:author) { create(:user, :author) }
    let(:post)   { create(:post, author: author) }

    it 'returns only document attachments ordered by position' do
      img   = create(:media_attachment, user: author, attachable: post, position: 1)
      doc_b = create(:media_attachment, :document, user: author, attachable: post, position: 5)
      doc_a = create(:media_attachment, :document, user: author, attachable: post, position: 1)

      expect(post.documents.to_a).to eq([ doc_a, doc_b ])
      expect(post.documents).not_to include(img)
    end
  end

  describe '#source_url' do
    it 'prefers the manually edited source URL' do
      post = build(:post, source_url: 'https://example.com/source', external_source: 'ukr_pravda_blog', external_id: 'muzhdabaev/69e3cf895b986')
      expect(post.source_url).to eq('https://example.com/source')
    end

    it 'allows clearing an imported source URL' do
      post = build(:post, source_url: '', external_source: 'ukr_pravda_blog', external_id: 'muzhdabaev/69e3cf895b986')
      expect(post.source_url).to be_nil
    end

    it 'rebuilds the original blogs.pravda.com.ua URL for ukr_pravda_blog imports' do
      post = build(:post, external_source: 'ukr_pravda_blog', external_id: 'muzhdabaev/69e3cf895b986')
      expect(post.source_url).to eq('https://blogs.pravda.com.ua/authors/muzhdabaev/69e3cf895b986/')
    end

    it 'returns nil when the post has no external source' do
      post = build(:post, external_source: nil, external_id: nil)
      expect(post.source_url).to be_nil
    end

    it 'returns nil when the external_id is missing the author/hash split' do
      post = build(:post, external_source: 'ukr_pravda_blog', external_id: 'broken')
      expect(post.source_url).to be_nil
    end

    it 'returns nil for unknown external sources' do
      post = build(:post, external_source: 'some_other_feed', external_id: 'a/b')
      expect(post.source_url).to be_nil
    end
  end

  describe '#display_source_name' do
    it 'prefers the manually edited source name' do
      post = build(:post, source_name: 'Ukrainian Pravda', external_source: 'ukr_pravda_blog')
      expect(post.display_source_name).to eq('Ukrainian Pravda')
    end

    it 'falls back to the import source identifier' do
      post = build(:post, source_name: nil, external_source: 'youtube')
      expect(post.display_source_name).to eq('youtube')
    end
  end

  it_behaves_like 'sluggable'
  it_behaves_like 'publishable'
  it_behaves_like 'taggable'
  it_behaves_like 'reactable'
  it_behaves_like 'commentable'
  it_behaves_like 'translatable', :title, :subtitle, :lead, :content
end
