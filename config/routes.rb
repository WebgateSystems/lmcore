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
    resources :themes
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

  # Author/Moderator Dashboard
  namespace :dashboard do
    root "home#index"
    get "locale/:interface_locale", to: "base#switch_locale", as: :switch_locale
    resources :posts do
      member do
        post :pin
      end
    end
    resources :videos do
      collection do
        post :sync_youtube
        get :sync_status
      end
      member do
        post :create_post_from_video
        post :pin
      end
    end
    resources :gallery, controller: "albums", param: :slug do
      member do
        post :pin
      end
      resources :photos, controller: "gallery_photos", only: %i[create update destroy] do
        collection do
          post :reorder
        end
        member do
          post :make_cover
          post :move
        end
      end
    end
    resources :pages
    resource :menu, only: %i[show update], controller: "menu"
    resources :categories, only: %i[index show new create edit update destroy]
    resources :tags, only: %i[index show new create edit update destroy]
    resource :settings, only: %i[show update]
    resources :partners, only: %i[index new create edit update destroy] do
      collection do
        post :reorder
      end
    end
    resources :comments, only: %i[index show update destroy]
    resources :audience, only: %i[index] do
      collection do
        post :ban
        post :trust
        delete :untrust
      end
    end
    resources :audit_logs, only: %i[index show]
    resources :team, only: %i[index create destroy] do
      member do
        patch :update_role
      end
    end
    resources :team_invitations, only: %i[create destroy] do
      member do
        post :resend
      end
    end
  end

  # Devise routes
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "register"
  }, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  use_doorkeeper do
    skip_controllers :authorized_applications
  end
  use_doorkeeper_openid_connect

  get "sso/login", to: "sso#login", as: :sso_login
  get "sso/callback", to: "sso#callback", as: :sso_callback
  get "sso/consume", to: "sso#consume", as: :sso_consume
  delete "sso/logout", to: "sso#logout", as: :sso_logout

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      devise_for :users, path: "auth", skip: %i[omniauth_callbacks], controllers: {
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
      resources :media_attachments, only: %i[index show create update destroy]

      # Settings
      resource :settings, only: %i[show update]
    end
  end

  # Blog routes — Liquid-rendered per-user blogs
  scope "blogs/:blog_slug", as: :blog do
    get "/", to: "blogs#show"
    get "posts", to: "blogs#posts", as: :posts
    get "posts/:slug", to: "blogs#post", as: :post
    post "posts/:post_slug/comments", to: "comments#create", as: :post_comments
    post "contact_messages", to: "blog_contact_messages#create", as: :contact_messages
    post "newsletter_subscriptions", to: "blog_newsletter_subscriptions#create", as: :newsletter_subscriptions
    get "videos", to: "blogs#videos", as: :videos
    get "videos/:slug", to: "blogs#video", as: :video
    post "videos/:video_slug/comments", to: "comments#create", as: :video_comments
    get "gallery", to: "blogs#gallery", as: :gallery
    get "gallery/:slug", to: "blogs#album", as: :album
    post "gallery/:album_slug/comments", to: "comments#create", as: :album_comments
    get "categories/:slug", to: "blogs#category", as: :category
    get "tags/:slug", to: "blogs#tag", as: :tag
    get "pages/:slug", to: "blogs#page", as: :page
    get "search", to: "blogs#search", as: :search
    get "locale/:locale", to: "blogs#switch_locale", as: :locale
  end

  # Locale switching
  get "locale/:locale", to: "locale#switch", as: :switch_locale

  # Frontend routes (will be handled by views/frontend)
  scope "(:locale)", locale: /en|pl|uk|ua|lt|de|fr|es|ru/ do
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
