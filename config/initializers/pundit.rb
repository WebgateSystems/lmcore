# frozen_string_literal: true

# Pundit configuration - authorization framework
# No special configuration needed, but we include this file for documentation

# Pundit will look for policy classes in app/policies/
# Policy classes should follow the naming convention: ModelPolicy
# e.g., PostPolicy for Post model

# Include Pundit in ApplicationController:
# include Pundit::Authorization
#
# After actions to verify authorization:
# after_action :verify_authorized, except: :index
# after_action :verify_policy_scoped, only: :index
