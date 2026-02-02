# frozen_string_literal: true

class HomeController < ApplicationController
  layout "landing"
  skip_before_action :authenticate_user!, only: [ :index ], raise: false

  def index
    @features = features_data
    @pricing_plans = pricing_data
    @partners = Partner.active.for_locale(I18n.locale).ordered
  end

  private

  def features_data
    [
      {
        icon: "fa-blog",
        title_key: "features.blog.title",
        description_key: "features.blog.description"
      },
      {
        icon: "fa-video",
        title_key: "features.video.title",
        description_key: "features.video.description"
      },
      {
        icon: "fa-comments",
        title_key: "features.forum.title",
        description_key: "features.forum.description"
      },
      {
        icon: "fa-lock",
        title_key: "features.chat.title",
        description_key: "features.chat.description"
      },
      {
        icon: "fa-broadcast-tower",
        title_key: "features.live.title",
        description_key: "features.live.description"
      },
      {
        icon: "fa-star",
        title_key: "features.reputation.title",
        description_key: "features.reputation.description"
      }
    ]
  end

  def pricing_data
    PricePlan.order(:position).map do |plan|
      {
        name: plan.name,
        slug: plan.slug,
        price: plan.price_cents,
        currency: plan.currency,
        period: plan.billing_period,
        features: plan.features,
        posts_limit: plan.posts_limit,
        disk_space_mb: plan.disk_space_mb
      }
    end
  rescue StandardError
    # Fallback if database not seeded
    []
  end
end
