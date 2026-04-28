# frozen_string_literal: true

class DoorkeeperBaseController < ApplicationController
  skip_after_action :verify_authorized, raise: false
  skip_after_action :verify_policy_scoped, raise: false
end
