# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'legal/license.html.slim' do
  before do
    allow(view).to receive(:root_path).and_return('/')
    allow(view).to receive(:license_path).and_return('/license')
    render template: 'legal/license', layout: false
  end

  it 'renders the page title' do
    expect(rendered).to have_css('h1.legal-title')
  end

  it 'renders the back link' do
    expect(rendered).to have_css('a.back-link')
  end

  it 'renders the license badge' do
    expect(rendered).to have_css('.license-badge .badge-type')
  end

  it 'includes the SACL-1.0 badge text' do
    expect(rendered).to include('SACL-1.0')
  end

  it 'renders copyright section' do
    expect(rendered).to include('Webgate Systems LTD')
  end

  it 'renders the "can do" section with list' do
    expect(rendered).to have_css('.license-list')
  end

  it 'includes success icons for allowed actions' do
    expect(rendered).to have_css('.fa-check.text-success')
  end

  it 'includes danger icons for restricted actions' do
    expect(rendered).to have_css('.fa-xmark.text-danger')
  end

  it 'renders the license highlight sections' do
    expect(rendered).to have_css('.license-highlight')
  end

  it 'includes the GitHub link' do
    expect(rendered).to have_link(href: 'https://github.com/WebgateSystems/lmcore/blob/main/LICENSE.md')
  end

  it 'includes the contact email' do
    expect(rendered).to have_link(href: 'mailto:legal@webgate.pro')
  end

  it 'includes webgate.pro link' do
    expect(rendered).to have_link(href: 'https://webgate.pro')
  end

  it 'renders the legal footer' do
    expect(rendered).to have_css('.legal-footer')
  end

  it 'includes copyright year' do
    expect(rendered).to include('2026')
  end
end
