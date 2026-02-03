# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locale", type: :request do
  describe "GET /locale/switch" do
    it "switches to a valid locale" do
      get switch_locale_path(locale: "pl")
      expect(session[:locale]).to eq("pl")
      expect(cookies[:locale]).to eq("pl")
    end

    it "redirects after switching" do
      get switch_locale_path(locale: "pl")
      expect(response).to have_http_status(:redirect)
    end

    it "handles invalid locales gracefully" do
      get switch_locale_path(locale: "invalid_locale")
      expect(response).to have_http_status(:redirect)
    end

    it "sets locale cookie with 1 year expiry" do
      get switch_locale_path(locale: "en")
      expect(cookies[:locale]).to eq("en")
    end

    context "with referer header" do
      it "redirects back with new locale" do
        get switch_locale_path(locale: "pl"), headers: { "HTTP_REFERER" => "http://example.com/en/posts" }
        expect(response).to have_http_status(:redirect)
      end

      it "replaces existing locale in path" do
        get switch_locale_path(locale: "pl"), headers: { "HTTP_REFERER" => "http://example.com/en/posts" }
        expect(response).to redirect_to("/pl/posts")
      end
    end

    context "without referer" do
      it "redirects to root with new locale" do
        get switch_locale_path(locale: "pl")
        expect(response).to redirect_to(root_path(locale: "pl"))
      end
    end

    context "with different locales" do
      %w[en pl uk lt de fr es].each do |locale|
        it "accepts #{locale} locale" do
          get switch_locale_path(locale: locale)
          expect(session[:locale]).to eq(locale)
        end
      end
    end
  end
end
