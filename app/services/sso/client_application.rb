# frozen_string_literal: true

module Sso
  class ClientApplication
    class << self
      def ensure_for_redirect!(redirect_uri)
        app = Doorkeeper::Application.find_or_initialize_by(uid: Settings.sso.client_uid)
        app.name = Settings.sso.client_name
        app.secret = Settings.sso.client_secret
        app.confidential = true
        app.scopes = "openid profile email offline_access"
        app.redirect_uri = merged_redirect_uris(app.redirect_uri, redirect_uri)
        app.save!
        app
      end

      private

      def merged_redirect_uris(existing, redirect_uri)
        values = existing.to_s.split(/\s+/).reject(&:blank?)
        values << redirect_uri
        values.uniq.join("\n")
      end
    end
  end
end
