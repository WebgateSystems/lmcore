# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'home/_partners.html.slim' do
  let!(:partner1) do
    create(:partner,
      name: 'Test Partner',
      url: 'https://example.com',
      icon_class: 'fa-brands fa-youtube',
      locale: 'en',
      description_i18n: { 'en' => 'Test description' }
    )
  end

  let!(:partner2) do
    create(:partner,
      name: 'Another Partner',
      url: 'https://another.com',
      icon_class: 'fa-solid fa-newspaper',
      locale: 'en',
      description_i18n: { 'en' => 'Another description' }
    )
  end

  let(:partners) { Partner.active.for_locale('en').ordered }

  before do
    render partial: 'home/partners', locals: { partners: partners }
  end

  it 'renders the carousel container' do
    expect(rendered).to have_css('.partners-carousel[data-controller="carousel"]')
  end

  it 'renders carousel navigation arrows' do
    expect(rendered).to have_css('.carousel-arrow-prev')
    expect(rendered).to have_css('.carousel-arrow-next')
  end

  it 'renders partner cards' do
    expect(rendered).to have_css('.partner-card', count: 2)
  end

  it 'renders partner names' do
    expect(rendered).to include('Test Partner')
    expect(rendered).to include('Another Partner')
  end

  it 'renders partner URLs as links' do
    expect(rendered).to have_link(href: 'https://example.com')
    expect(rendered).to have_link(href: 'https://another.com')
  end

  it 'renders partner icons' do
    expect(rendered).to have_css('i.fa-brands.fa-youtube')
    expect(rendered).to have_css('i.fa-solid.fa-newspaper')
  end

  it 'renders partner descriptions' do
    expect(rendered).to include('Test description')
    expect(rendered).to include('Another description')
  end

  it 'opens links in new tab' do
    expect(rendered).to have_css('a.partner-card[target="_blank"]', count: 2)
  end

  it 'includes noopener for security' do
    expect(rendered).to have_css('a.partner-card[rel="noopener"]', count: 2)
  end

  it 'sets carousel auto-scroll interval' do
    expect(rendered).to have_css('[data-carousel-interval-value="7000"]')
  end
end
