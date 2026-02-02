# frozen_string_literal: true

set :stage, :production
set :branch, ENV.fetch("BRANCH", "main")
set :deploy_user, "lmweb"

set :full_app_name, "libremedia.org"
set :server_name, fetch(:full_app_name)

server fetch(:server_name), user: fetch(:deploy_user), roles: %w[web app db], primary: true

set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:full_app_name)}"

set :rails_env, :production
