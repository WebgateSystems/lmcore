# frozen_string_literal: true

class DeviseParentController < ApplicationController
  layout "auth"

  skip_before_action :authenticate_user!, raise: false
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false
end
