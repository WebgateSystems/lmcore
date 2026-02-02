# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legal Pages' do
  describe 'GET /license' do
    it 'returns a successful response' do
      get license_path
      expect(response).to have_http_status(:ok)
    end

    it 'renders the landing layout' do
      get license_path
      expect(response.body).to include('LibreMedia')
    end

    it 'displays the license title' do
      get license_path
      expect(response.body).to include('License')
    end

    it 'displays the license badge' do
      get license_path
      expect(response.body).to include('SACL-1.0')
    end

    it 'displays the copyright holder' do
      get license_path
      expect(response.body).to include('Webgate Systems LTD')
    end

    it 'includes link to GitHub repository' do
      get license_path
      expect(response.body).to include('github.com/WebgateSystems/lmcore')
    end

    it 'includes contact email' do
      get license_path
      expect(response.body).to include('legal@webgate.pro')
    end

    it 'does not require authentication' do
      get license_path
      expect(response).not_to have_http_status(:unauthorized)
      expect(response).not_to have_http_status(:redirect)
    end

    context 'with Polish locale' do
      it 'displays Polish translations' do
        get license_path, params: { locale: 'pl' }
        expect(response.body).to include('Licencja')
      end

      it 'displays Polish content' do
        get license_path, params: { locale: 'pl' }
        expect(response.body).to include('Informacja o prawach autorskich')
      end
    end

    context 'with Ukrainian locale' do
      it 'displays Ukrainian translations' do
        get license_path, params: { locale: 'uk' }
        expect(response.body).to include('Ліцензія')
      end

      it 'displays Ukrainian content' do
        get license_path, params: { locale: 'uk' }
        expect(response.body).to include('Інформація про авторські права')
      end
    end

    context 'with English locale' do
      it 'displays English translations' do
        get license_path, params: { locale: 'en' }
        expect(response.body).to include('License')
      end

      it 'displays English content' do
        get license_path, params: { locale: 'en' }
        expect(response.body).to include('Copyright Notice')
      end
    end
  end

  describe 'GET /privacy' do
    it 'returns a successful response' do
      get privacy_path
      expect(response).to have_http_status(:ok)
    end

    it 'does not require authentication' do
      get privacy_path
      expect(response).not_to have_http_status(:unauthorized)
    end

    context 'with Polish locale' do
      it 'displays Polish title' do
        get privacy_path, params: { locale: 'pl' }
        expect(response.body).to include('Polityka Prywatności')
      end
    end
  end

  describe 'GET /terms' do
    it 'returns a successful response' do
      get terms_path
      expect(response).to have_http_status(:ok)
    end

    it 'does not require authentication' do
      get terms_path
      expect(response).not_to have_http_status(:unauthorized)
    end

    context 'with Polish locale' do
      it 'displays Polish title' do
        get terms_path, params: { locale: 'pl' }
        expect(response.body).to include('Regulamin')
      end
    end
  end

  describe 'authorization' do
    it 'does not trigger Pundit authorization for license' do
      expect { get license_path }.not_to raise_error
    end

    it 'does not trigger Pundit authorization for privacy' do
      expect { get privacy_path }.not_to raise_error
    end

    it 'does not trigger Pundit authorization for terms' do
      expect { get terms_path }.not_to raise_error
    end
  end

  describe 'footer links' do
    it 'includes license link in home page footer' do
      get root_path
      expect(response.body).to include('href="/license"').or include('href="/en/license"').or include('href="/pl/license"')
    end

    it 'includes privacy link in home page footer' do
      get root_path
      expect(response.body).to include('href="/privacy"').or include('href="/en/privacy"').or include('href="/pl/privacy"')
    end

    it 'includes terms link in home page footer' do
      get root_path
      expect(response.body).to include('href="/terms"').or include('href="/en/terms"').or include('href="/pl/terms"')
    end
  end
end
