# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  get "health", to: "home#spinup_status"
  get "version", to: "home#version"

  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Sidekiq Web UI (admin only)
  require "sidekiq/web"
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # Stop impersonating
  delete "stop_impersonating", to: "application#stop_impersonating", as: :stop_impersonating

  # Admin Panel
  namespace :admin do
    root "dashboard#index"

    resources :users do
      member do
        post :suspend
        post :activate
        post :change_role
        post :add_role
        delete :remove_role
        post :impersonate
      end
    end

    resources :posts do
      member do
        post :publish
        post :unpublish
        post :feature
      end
    end

    resources :videos do
      member do
        post :publish
        post :unpublish
      end
    end

    resources :photos do
      member do
        post :publish
        post :unpublish
      end
    end

    resources :pages do
      member do
        post :publish
        post :unpublish
      end
    end

    resources :categories
    resources :tags
    resources :audit_logs, only: %i[index show]

    namespace :api, defaults: { format: :json } do
      namespace :v1 do
        resources :users, only: %i[index show update destroy] do
          member do
            post :suspend
            post :activate
            post :change_role
          end
        end
        resources :stats, only: [ :index ]
        resources :activity, only: [ :index ]
      end
    end
  end

  # Devise routes
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "register"
  }

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      devise_for :users, path: "auth", controllers: {
        sessions: "api/v1/sessions",
        registrations: "api/v1/registrations"
      }

      # Resources
      resources :posts do
        member do
          post :publish
          post :unpublish
          post :archive
        end
        resources :comments, shallow: true
      end

      resources :videos do
        member do
          post :publish
        end
        resources :comments, shallow: true
      end

      resources :photos do
        member do
          post :publish
        end
        resources :comments, shallow: true
      end

      resources :categories
      resources :tags, only: %i[index show]
      resources :pages

      # User profile
      resource :profile, only: %i[show update]
      resources :notifications, only: %i[index show] do
        collection do
          post :mark_all_read
        end
        member do
          post :read
        end
      end

      # Following
      resources :users, only: %i[index show] do
        member do
          post :follow
          delete :unfollow
        end
        resources :posts, only: :index, controller: "users/posts"
      end

      # Subscriptions & Payments
      resources :subscriptions, only: %i[index show create] do
        member do
          post :cancel
        end
      end
      resources :payments, only: %i[index show]
      resources :donations, only: %i[index create]

      # Media
      resources :media_attachments, only: %i[index create destroy]

      # Settings
      resource :settings, only: %i[show update]
    end
  end

  # Locale switching
  get "locale/:locale", to: "locale#switch", as: :switch_locale

  # Frontend routes (will be handled by views/frontend)
  scope "(:locale)", locale: /en|pl|uk|lt|de|fr|es/ do
    root "home#index"

    # Legal pages
    get "license", to: "legal#license", as: :license
    get "privacy", to: "legal#privacy", as: :privacy
    get "terms", to: "legal#terms", as: :terms

    resources :posts, only: %i[index show], param: :slug
    resources :videos, only: %i[index show], param: :slug
    resources :photos, only: %i[index show], param: :slug
    resources :categories, only: %i[index show], param: :slug
    resources :tags, only: %i[index show], param: :slug
    resources :pages, only: :show, param: :slug, path: "", constraints: { slug: /[^.]+/ }

    # User profiles
    get "@:username", to: "profiles#show", as: :user_profile
  end
end
