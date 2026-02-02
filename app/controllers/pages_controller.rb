# frozen_string_literal: true

class PagesController < ApplicationController
  layout "landing"

  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show
    @page = Page.find_by!(slug: params[:slug])
    @title = @page.title
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError, "Not Found"
  end
end
