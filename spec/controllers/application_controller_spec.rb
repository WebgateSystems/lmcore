# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    def index
      render plain: 'ok'
    end
  end

  describe '#skip_authorization?' do
    it 'skips authorization for health controller' do
      allow(controller).to receive(:controller_name).and_return('health')
      expect(controller.send(:skip_authorization?)).to be true
    end

    it 'skips authorization for home controller' do
      allow(controller).to receive(:controller_name).and_return('home')
      expect(controller.send(:skip_authorization?)).to be true
    end

    it 'skips authorization for locale controller' do
      allow(controller).to receive(:controller_name).and_return('locale')
      expect(controller.send(:skip_authorization?)).to be true
    end

    it 'skips authorization for legal controller' do
      allow(controller).to receive(:controller_name).and_return('legal')
      expect(controller.send(:skip_authorization?)).to be true
    end

    it 'does not skip authorization for other controllers' do
      allow(controller).to receive(:controller_name).and_return('posts')
      allow(controller).to receive(:devise_controller?).and_return(false)
      expect(controller.send(:skip_authorization?)).to be false
    end

    it 'skips authorization for devise controllers' do
      allow(controller).to receive(:controller_name).and_return('sessions')
      allow(controller).to receive(:devise_controller?).and_return(true)
      expect(controller.send(:skip_authorization?)).to be true
    end
  end

  describe '#set_locale' do
    before do
      # Reset locale before each test
      I18n.locale = I18n.default_locale
    end

    it 'sets locale from params when valid' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(locale: 'uk'))
      allow(controller).to receive(:session).and_return({})
      allow(controller).to receive(:cookies).and_return({})
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive_message_chain(:request, :env).and_return({})

      controller.send(:set_locale)
      expect(I18n.locale).to eq(:uk)
    end

    it 'falls back to default locale for invalid locale' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(locale: 'invalid'))
      allow(controller).to receive(:session).and_return({})
      allow(controller).to receive(:cookies).and_return({})
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive_message_chain(:request, :env).and_return({})

      controller.send(:set_locale)
      expect(I18n.locale).to eq(I18n.default_locale)
    end

    it 'uses session locale when params not provided' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new({}))
      allow(controller).to receive(:session).and_return({ locale: 'pl' })
      allow(controller).to receive(:cookies).and_return({})
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive_message_chain(:request, :env).and_return({})

      controller.send(:set_locale)
      expect(I18n.locale).to eq(:pl)
    end

    it 'uses cookie locale when params and session not provided' do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new({}))
      allow(controller).to receive(:session).and_return({})
      allow(controller).to receive(:cookies).and_return({ locale: 'uk' })
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive_message_chain(:request, :env).and_return({})

      controller.send(:set_locale)
      expect(I18n.locale).to eq(:uk)
    end
  end
end
