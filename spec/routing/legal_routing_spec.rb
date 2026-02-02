# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legal routes' do
  describe 'license' do
    it 'routes /license to legal#license' do
      expect(get: '/license').to route_to(controller: 'legal', action: 'license')
    end

    it 'routes /en/license to legal#license with English locale' do
      expect(get: '/en/license').to route_to(controller: 'legal', action: 'license', locale: 'en')
    end

    it 'routes /pl/license to legal#license with Polish locale' do
      expect(get: '/pl/license').to route_to(controller: 'legal', action: 'license', locale: 'pl')
    end

    it 'routes /uk/license to legal#license with Ukrainian locale' do
      expect(get: '/uk/license').to route_to(controller: 'legal', action: 'license', locale: 'uk')
    end
  end

  describe 'privacy' do
    it 'routes /privacy to legal#privacy' do
      expect(get: '/privacy').to route_to(controller: 'legal', action: 'privacy')
    end

    it 'routes /en/privacy to legal#privacy with English locale' do
      expect(get: '/en/privacy').to route_to(controller: 'legal', action: 'privacy', locale: 'en')
    end

    it 'routes /pl/privacy to legal#privacy with Polish locale' do
      expect(get: '/pl/privacy').to route_to(controller: 'legal', action: 'privacy', locale: 'pl')
    end
  end

  describe 'terms' do
    it 'routes /terms to legal#terms' do
      expect(get: '/terms').to route_to(controller: 'legal', action: 'terms')
    end

    it 'routes /en/terms to legal#terms with English locale' do
      expect(get: '/en/terms').to route_to(controller: 'legal', action: 'terms', locale: 'en')
    end

    it 'routes /pl/terms to legal#terms with Polish locale' do
      expect(get: '/pl/terms').to route_to(controller: 'legal', action: 'terms', locale: 'pl')
    end
  end

  describe 'named routes' do
    it 'generates license_path' do
      expect(license_path).to eq('/license')
    end

    it 'generates privacy_path' do
      expect(privacy_path).to eq('/privacy')
    end

    it 'generates terms_path' do
      expect(terms_path).to eq('/terms')
    end

    it 'generates license_path with locale' do
      expect(license_path(locale: 'pl')).to eq('/pl/license')
    end

    it 'generates privacy_path with locale' do
      expect(privacy_path(locale: 'uk')).to eq('/uk/privacy')
    end
  end
end
