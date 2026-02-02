# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Partner do
  describe 'validations' do
    subject { build(:partner) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }

    it 'generates slug automatically when blank' do
      partner = build(:partner, slug: nil)
      partner.valid?
      expect(partner.slug).to be_present
    end

    it 'validates url format when present' do
      partner = build(:partner, url: 'invalid-url')
      expect(partner).not_to be_valid
      expect(partner.errors[:url]).to be_present
    end

    it 'allows blank url' do
      partner = build(:partner, url: '')
      partner.valid?
      expect(partner.errors[:url]).to be_empty
    end

    it 'allows valid http url' do
      partner = build(:partner, url: 'http://example.com')
      expect(partner).to be_valid
    end

    it 'allows valid https url' do
      partner = build(:partner, url: 'https://example.com/path')
      expect(partner).to be_valid
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active partners' do
        active = create(:partner, active: true)
        inactive = create(:partner, active: false)

        expect(described_class.active).to include(active)
        expect(described_class.active).not_to include(inactive)
      end
    end

    describe '.inactive' do
      it 'returns only inactive partners' do
        active = create(:partner, active: true)
        inactive = create(:partner, active: false)

        expect(described_class.inactive).to include(inactive)
        expect(described_class.inactive).not_to include(active)
      end
    end

    describe '.ordered' do
      it 'orders by position ascending' do
        third = create(:partner, position: 3)
        first = create(:partner, position: 1)
        second = create(:partner, position: 2)

        expect(described_class.ordered).to eq([ first, second, third ])
      end
    end

    describe '.for_locale' do
      it 'filters partners by locale' do
        polish = create(:partner, :polish)
        ukrainian = create(:partner, :ukrainian)
        english = create(:partner, :english)

        expect(described_class.for_locale('pl')).to include(polish)
        expect(described_class.for_locale('pl')).not_to include(ukrainian, english)

        expect(described_class.for_locale('uk')).to include(ukrainian)
        expect(described_class.for_locale('uk')).not_to include(polish, english)

        expect(described_class.for_locale('en')).to include(english)
        expect(described_class.for_locale('en')).not_to include(polish, ukrainian)
      end

      it 'works with symbol locale' do
        polish = create(:partner, :polish)

        expect(described_class.for_locale(:pl)).to include(polish)
      end
    end

    describe 'chained scopes' do
      it 'can combine active, for_locale, and ordered' do
        active_pl_1 = create(:partner, :polish, active: true, position: 2)
        active_pl_2 = create(:partner, :polish, active: true, position: 1)
        inactive_pl = create(:partner, :polish, active: false, position: 0)
        active_en = create(:partner, :english, active: true, position: 0)

        result = described_class.active.for_locale('pl').ordered

        expect(result).to eq([ active_pl_2, active_pl_1 ])
        expect(result).not_to include(inactive_pl, active_en)
      end
    end
  end

  describe 'instance methods' do
    describe '#activate!' do
      it 'sets active to true' do
        partner = create(:partner, active: false)
        partner.activate!

        expect(partner.reload.active).to be true
      end
    end

    describe '#deactivate!' do
      it 'sets active to false' do
        partner = create(:partner, active: true)
        partner.deactivate!

        expect(partner.reload.active).to be false
      end
    end

    describe '#logo' do
      it 'returns logo_svg when present' do
        partner = build(:partner, logo_svg: '<svg></svg>', logo_url: 'http://example.com/logo.png')
        expect(partner.logo).to eq('<svg></svg>')
      end

      it 'returns logo_url when logo_svg is blank' do
        partner = build(:partner, logo_svg: nil, logo_url: 'http://example.com/logo.png')
        expect(partner.logo).to eq('http://example.com/logo.png')
      end

      it 'returns nil when both are blank' do
        partner = build(:partner, logo_svg: nil, logo_url: nil)
        expect(partner.logo).to be_nil
      end
    end

    describe '#has_logo?' do
      it 'returns true when logo_svg is present' do
        partner = build(:partner, logo_svg: '<svg></svg>')
        expect(partner.has_logo?).to be true
      end

      it 'returns true when logo_url is present' do
        partner = build(:partner, logo_url: 'http://example.com/logo.png')
        expect(partner.has_logo?).to be true
      end

      it 'returns false when both are blank' do
        partner = build(:partner, logo_svg: nil, logo_url: nil)
        expect(partner.has_logo?).to be false
      end
    end

    describe '#svg_logo?' do
      it 'returns true when logo_svg is present' do
        partner = build(:partner, logo_svg: '<svg></svg>')
        expect(partner.svg_logo?).to be true
      end

      it 'returns false when logo_svg is blank' do
        partner = build(:partner, logo_svg: nil)
        expect(partner.svg_logo?).to be false
      end
    end
  end

  describe 'translations' do
    describe '#description' do
      it 'returns description for current locale' do
        partner = build(:partner, description_i18n: { 'en' => 'English desc', 'pl' => 'Polski opis' })

        I18n.with_locale(:en) do
          expect(partner.description).to eq('English desc')
        end

        I18n.with_locale(:pl) do
          expect(partner.description).to eq('Polski opis')
        end
      end

      it 'falls back to default locale when current is missing' do
        partner = build(:partner, description_i18n: { 'en' => 'English only' })

        I18n.with_locale(:pl) do
          expect(partner.description).to eq('English only')
        end
      end
    end
  end

  it_behaves_like 'sluggable'
  it_behaves_like 'translatable', :description
end
