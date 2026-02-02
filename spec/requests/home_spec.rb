# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home' do
  let(:path) { '/version' }

  describe '#GET /version' do
    before do
      allow(AppIdService).to receive(:version).and_return('hash_of_the_last_commit')
      get path
    end

    it 'responds with HTTP 200 status' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with AppIdService.version as a plain string' do
      expect(response.body).to eq('hash_of_the_last_commit')
    end
  end

  describe '#GET /version.json' do
    let(:version_json) { { version: 'hash_of_the_last_commit' }.to_json }

    before do
      allow(AppIdService).to receive(:version).and_return('hash_of_the_last_commit')
      get '/version.json'
    end

    it 'responds with HTTP 200 status' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with JSON format' do
      expect(response.content_type).to include('application/json')
    end

    it 'responds with AppIdService.version as a plain string' do
      expect(response.body).to eq(version_json)
    end
  end

  describe '#GET /health' do
    before do
      get '/health'
    end

    it 'responds with HTTP 200 status' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with OK as a plain string' do
      expect(response.body).to eq('OK')
    end
  end

  describe 'GET /' do
    it 'returns a successful response' do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it 'renders the landing layout' do
      get root_path
      expect(response.body).to include('LibreMedia')
    end

    context 'with partners' do
      let!(:polish_partner) { create(:partner, :polish, name: 'Polski Partner', active: true) }
      let!(:ukrainian_partner) { create(:partner, :ukrainian, name: 'Український партнер', active: true) }
      let!(:english_partner) { create(:partner, :english, name: 'English Partner', active: true) }
      let!(:inactive_partner) { create(:partner, :polish, name: 'Inactive', active: false) }

      context 'with Polish locale' do
        before { get root_path, headers: { 'Accept-Language' => 'pl' } }

        it 'shows Polish partners' do
          expect(response.body).to include('Polski Partner')
        end

        it 'does not show Ukrainian partners' do
          expect(response.body).not_to include('Український партнер')
        end

        it 'does not show English partners' do
          expect(response.body).not_to include('English Partner')
        end

        it 'does not show inactive partners' do
          expect(response.body).not_to include('Inactive')
        end
      end

      context 'with Ukrainian locale' do
        before { get root_path, params: { locale: 'uk' } }

        it 'shows Ukrainian partners' do
          expect(response.body).to include('Український партнер')
        end

        it 'does not show Polish partners' do
          expect(response.body).not_to include('Polski Partner')
        end
      end

      context 'with English locale' do
        before { get root_path, params: { locale: 'en' } }

        it 'shows English partners' do
          expect(response.body).to include('English Partner')
        end

        it 'does not show Polish partners' do
          expect(response.body).not_to include('Polski Partner')
        end
      end
    end

    context 'partners ordering' do
      let!(:partner_third) { create(:partner, :english, name: 'Third', position: 3) }
      let!(:partner_first) { create(:partner, :english, name: 'First', position: 1) }
      let!(:partner_second) { create(:partner, :english, name: 'Second', position: 2) }

      it 'displays partners in position order' do
        get root_path, params: { locale: 'en' }

        first_pos = response.body.index('First')
        second_pos = response.body.index('Second')
        third_pos = response.body.index('Third')

        expect(first_pos).to be < second_pos
        expect(second_pos).to be < third_pos
      end
    end

    context 'when no partners exist for locale' do
      let!(:english_partner) { create(:partner, :english, name: 'English Only') }

      it 'does not show partners section content for Polish locale' do
        get root_path, params: { locale: 'pl' }
        # The section header will still be there, but no partner cards
        expect(response.body).not_to include('English Only')
      end
    end
  end

  describe 'partners caching' do
    let!(:partner) { create(:partner, :polish, name: 'Cached Partner') }

    it 'caches partners partial by locale' do
      # First request - cache miss
      get root_path, params: { locale: 'pl' }
      expect(response.body).to include('Cached Partner')

      # Update partner (would invalidate cache due to cache_key_with_version)
      partner.update!(name: 'Updated Partner')

      # Second request - should show updated content
      get root_path, params: { locale: 'pl' }
      expect(response.body).to include('Updated Partner')
    end
  end
end
