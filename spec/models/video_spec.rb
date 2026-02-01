# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Video do
  describe 'validations' do
    subject { build(:video) }

    it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:author_id) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[draft pending scheduled published archived]) }
    it { is_expected.to validate_inclusion_of(:video_provider).in_array(%w[youtube vimeo self_hosted]).allow_nil }

    it 'validates video_external_id presence for external providers' do
      video = build(:video, video_provider: 'youtube', video_external_id: nil)
      expect(video).not_to be_valid
    end

    it 'validates video source is present' do
      video = build(:video, video_provider: nil, video_url: nil, video_external_id: nil)
      video.video_file = nil
      expect(video).not_to be_valid
      expect(video.errors[:base]).to include('must have a video source (URL, file, or external ID)')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:category).optional }
    it { is_expected.to have_many(:comments) }
    it { is_expected.to have_many(:reactions) }
    it { is_expected.to have_many(:tags) }
  end

  describe '#embed_url' do
    it 'returns YouTube embed URL' do
      video = build(:video, :youtube, video_external_id: 'abc123')
      expect(video.embed_url).to eq('https://www.youtube.com/embed/abc123')
    end

    it 'returns Vimeo embed URL' do
      video = build(:video, :vimeo, video_external_id: '123456')
      expect(video.embed_url).to eq('https://player.vimeo.com/video/123456')
    end

    it 'returns video_url for self-hosted' do
      video = build(:video, :self_hosted, video_url: 'https://example.com/video.mp4')
      expect(video.embed_url).to eq('https://example.com/video.mp4')
    end
  end

  describe '#duration_formatted' do
    it 'formats duration in minutes and seconds' do
      video = build(:video, duration_seconds: 125)
      expect(video.duration_formatted).to eq('2:05')
    end

    it 'formats duration with hours' do
      video = build(:video, duration_seconds: 3725)
      expect(video.duration_formatted).to eq('1:02:05')
    end

    it 'returns nil when duration is not set' do
      video = build(:video, duration_seconds: nil)
      expect(video.duration_formatted).to be_nil
    end
  end

  describe '#self_hosted?' do
    it 'returns true for self-hosted videos' do
      video = build(:video, :self_hosted)
      expect(video.self_hosted?).to be true
    end

    it 'returns false for external videos' do
      video = build(:video, :youtube)
      expect(video.self_hosted?).to be false
    end
  end

  it_behaves_like 'sluggable'
  it_behaves_like 'publishable'
  it_behaves_like 'taggable'
  it_behaves_like 'reactable'
  it_behaves_like 'commentable'
end
