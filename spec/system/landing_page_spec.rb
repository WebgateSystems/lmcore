# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Landing Page', type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'partners section' do
    context 'with Polish locale' do
      let!(:partner1) { create(:partner, :polish, name: 'checkPRESS', position: 0) }
      let!(:partner2) { create(:partner, :polish, name: 'Radio Rebeliant', position: 1) }
      let!(:english_partner) { create(:partner, :english, name: 'The Guardian') }

      before do
        visit root_path(locale: 'pl')
      end

      it 'displays the partners section' do
        expect(page).to have_css('#partners')
      end

      it 'shows Polish partners' do
        within('#partners') do
          expect(page).to have_content('checkPRESS')
          expect(page).to have_content('Radio Rebeliant')
        end
      end

      it 'does not show English partners' do
        within('#partners') do
          expect(page).not_to have_content('The Guardian')
        end
      end

      it 'displays partner cards with proper structure' do
        within('#partners') do
          expect(page).to have_css('.partner-card', count: 2)
          expect(page).to have_css('.partner-logo')
          expect(page).to have_css('.partner-info')
        end
      end

      it 'displays carousel navigation arrows' do
        within('#partners') do
          expect(page).to have_css('.carousel-arrow-prev')
          expect(page).to have_css('.carousel-arrow-next')
        end
      end
    end

    context 'with Ukrainian locale' do
      let!(:partner) { create(:partner, :ukrainian, name: 'Українська правда') }
      let!(:polish_partner) { create(:partner, :polish, name: 'Polski Partner') }

      before do
        visit root_path(locale: 'uk')
      end

      it 'shows Ukrainian partners' do
        within('#partners') do
          expect(page).to have_content('Українська правда')
        end
      end

      it 'does not show Polish partners' do
        within('#partners') do
          expect(page).not_to have_content('Polski Partner')
        end
      end
    end

    context 'with English locale' do
      let!(:partner) { create(:partner, :english, name: 'The Daily Show') }

      before do
        visit root_path(locale: 'en')
      end

      it 'shows English partners' do
        within('#partners') do
          expect(page).to have_content('The Daily Show')
        end
      end
    end

    context 'with no partners' do
      before do
        visit root_path(locale: 'pl')
      end

      it 'does not show the carousel when no partners exist' do
        expect(page).not_to have_css('.partners-carousel')
      end
    end

    context 'with inactive partners' do
      let!(:active_partner) { create(:partner, :polish, name: 'Active Partner', active: true) }
      let!(:inactive_partner) { create(:partner, :polish, name: 'Inactive Partner', active: false) }

      before do
        visit root_path(locale: 'pl')
      end

      it 'shows only active partners' do
        within('#partners') do
          expect(page).to have_content('Active Partner')
          expect(page).not_to have_content('Inactive Partner')
        end
      end
    end
  end

  describe 'partners section translations' do
    let!(:partner) { create(:partner, :polish) }

    it 'shows section title in Polish' do
      visit root_path(locale: 'pl')
      expect(page).to have_content('Współpracujące Media i Liderzy Opinii')
    end

    it 'shows section title in English' do
      create(:partner, :english)
      visit root_path(locale: 'en')
      expect(page).to have_content('Partner Media and Opinion Leaders')
    end

    it 'shows section title in Ukrainian' do
      create(:partner, :ukrainian)
      visit root_path(locale: 'uk')
      expect(page).to have_content('Партнерські Медіа та Лідери Думок')
    end
  end

  describe 'partner links' do
    let!(:partner) do
      create(:partner, :polish,
        name: 'Test Partner',
        url: 'https://example.com/test'
      )
    end

    before do
      visit root_path(locale: 'pl')
    end

    it 'links to partner URL' do
      within('#partners') do
        expect(page).to have_link(href: 'https://example.com/test')
      end
    end
  end

  describe 'FAQ section' do
    before do
      visit root_path(locale: 'pl')
    end

    it 'displays the FAQ section' do
      expect(page).to have_css('#faq')
    end

    it 'displays FAQ title' do
      within('#faq') do
        expect(page).to have_css('.section-title')
      end
    end

    it 'displays FAQ items' do
      within('#faq') do
        expect(page).to have_css('.faq-item', minimum: 1)
      end
    end

    it 'displays FAQ questions as buttons' do
      within('#faq') do
        expect(page).to have_css('.faq-question', minimum: 1)
      end
    end

    it 'displays FAQ answers' do
      within('#faq') do
        expect(page).to have_css('.faq-answer', minimum: 1)
      end
    end

    it 'has accordion controller' do
      within('#faq') do
        expect(page).to have_css('[data-controller="accordion"]')
      end
    end

    it 'has chevron icons' do
      within('#faq') do
        expect(page).to have_css('.faq-icon.fa-chevron-down', minimum: 1)
      end
    end
  end

  describe 'FAQ translations' do
    it 'shows Polish FAQ title' do
      visit root_path(locale: 'pl')
      within('#faq') do
        expect(page).to have_content('Najczęściej Zadawane Pytania')
      end
    end

    it 'shows English FAQ title' do
      visit root_path(locale: 'en')
      within('#faq') do
        expect(page).to have_content('Frequently Asked Questions')
      end
    end

    it 'shows Ukrainian FAQ title' do
      visit root_path(locale: 'uk')
      within('#faq') do
        expect(page).to have_content('Часті Запитання')
      end
    end
  end

  describe 'About section' do
    before do
      visit root_path(locale: 'pl')
    end

    it 'displays the about section' do
      expect(page).to have_css('#about')
    end

    it 'displays about section before pricing' do
      about_position = page.body.index('id="about"')
      pricing_position = page.body.index('id="pricing"')
      expect(about_position).to be < pricing_position
    end
  end

  describe 'Section ordering' do
    before do
      visit root_path(locale: 'pl')
    end

    it 'displays sections in correct order: features, about, pricing, faq' do
      features_pos = page.body.index('id="features"')
      about_pos = page.body.index('id="about"')
      pricing_pos = page.body.index('id="pricing"')
      faq_pos = page.body.index('id="faq"')

      expect(features_pos).to be < about_pos
      expect(about_pos).to be < pricing_pos
      expect(pricing_pos).to be < faq_pos
    end
  end

  describe 'Footer legal links' do
    before do
      visit root_path(locale: 'pl')
    end

    it 'has license link in footer' do
      within('footer') do
        expect(page).to have_link('Licencja', href: /license/)
      end
    end

    it 'has privacy link in footer' do
      within('footer') do
        expect(page).to have_link('Polityka Prywatności', href: /privacy/)
      end
    end

    it 'has terms link in footer' do
      within('footer') do
        expect(page).to have_link('Regulamin', href: /terms/)
      end
    end
  end
end
