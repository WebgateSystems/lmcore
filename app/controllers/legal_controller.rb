# frozen_string_literal: true

class LegalController < ApplicationController
  layout "landing"

  def license
    @title = t("license.title")
  end

  def privacy
    @title = t("privacy.title")
  end

  def terms
    @title = t("footer.terms")
  end
end
