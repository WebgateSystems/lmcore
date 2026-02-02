# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legal Pages', type: :system do
  describe 'License page' do
    it 'displays the license page' do
      visit license_path
      expect(page).to have_css('h1', text: /License|Licencja|Ліцензія/)
    end

    it 'displays the license badge' do
      visit license_path
      expect(page).to have_css('.license-badge')
    end

    it 'displays what you can do section' do
      visit license_path
      expect(page).to have_css('.license-list .fa-check')
    end

    it 'displays what you cannot do section' do
      visit license_path
      expect(page).to have_css('.license-list .fa-xmark')
    end

    it 'has a back link to home page' do
      visit license_path
      expect(page).to have_css('a.back-link')
    end

    it 'displays contact information' do
      visit license_path
      expect(page).to have_content('legal@webgate.pro')
    end

    context 'with Polish locale' do
      it 'displays Polish content' do
        visit license_path(locale: 'pl')
        expect(page).to have_content('Licencja')
        expect(page).to have_content('Informacja o prawach autorskich')
      end
    end

    context 'with English locale' do
      it 'displays English content' do
        visit license_path(locale: 'en')
        expect(page).to have_content('License')
        expect(page).to have_content('Copyright Notice')
      end
    end

    context 'with Ukrainian locale' do
      it 'displays Ukrainian content' do
        visit license_path(locale: 'uk')
        expect(page).to have_content('Ліцензія')
        expect(page).to have_content('Інформація про авторські права')
      end
    end
  end

  describe 'Privacy page' do
    it 'displays the privacy page' do
      visit privacy_path
      expect(page).to have_css('h1.legal-title')
    end

    it 'has a back link' do
      visit privacy_path
      expect(page).to have_css('a.back-link')
    end
  end

  describe 'Terms page' do
    it 'displays the terms page' do
      visit terms_path
      expect(page).to have_css('h1.legal-title')
    end

    it 'has a back link' do
      visit terms_path
      expect(page).to have_css('a.back-link')
    end
  end

  describe 'Navigation from landing page' do
    it 'has license link in footer' do
      visit root_path
      within('footer') do
        expect(page).to have_link(href: /license/)
      end
    end

    it 'has privacy link in footer' do
      visit root_path
      within('footer') do
        expect(page).to have_link(href: /privacy/)
      end
    end

    it 'has terms link in footer' do
      visit root_path
      within('footer') do
        expect(page).to have_link(href: /terms/)
      end
    end

    it 'can navigate to license page from footer' do
      visit root_path
      within('footer') do
        click_link(href: /license/)
      end
      expect(page).to have_css('.license-badge')
    end
  end

  describe 'Back navigation' do
    it 'can navigate back to home from license page' do
      visit license_path
      click_link(class: 'back-link')
      expect(page).to have_css('.hero')
    end
  end
end
