# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    # Dashboard doesn't display scoped resources, just aggregated stats
    def verify_policy_scope?
      false
    end

    def index
      authorize :admin_dashboard, :index?

      # Load stats for dashboard widgets
      @stats = {
        users: user_stats,
        content: content_stats,
        engagement: engagement_stats,
        revenue: revenue_stats
      }

      # Recent activity
      @recent_users = User.kept.order(created_at: :desc).limit(5)
      @recent_posts = Post.order(created_at: :desc).limit(5)
      @recent_activity = AuditLog.order(created_at: :desc).limit(10)
    end

    private

    def user_stats
      {
        total: User.count,
        new_today: User.where("created_at >= ?", Time.current.beginning_of_day).count,
        new_this_week: User.where("created_at >= ?", 1.week.ago).count,
        new_this_month: User.where("created_at >= ?", 1.month.ago).count,
        active: User.active.count,
        suspended: User.suspended.count,
        pending: User.pending.count
      }
    end

    def content_stats
      {
        posts: Post.count,
        posts_published: Post.published.count,
        videos: Video.count,
        videos_published: Video.published.count,
        photos: Photo.count,
        photos_published: Photo.published.count,
        pages: Page.count
      }
    end

    def engagement_stats
      {
        comments: Comment.count,
        comments_today: Comment.where("created_at >= ?", Time.current.beginning_of_day).count,
        reactions: Reaction.count,
        reactions_today: Reaction.where("created_at >= ?", Time.current.beginning_of_day).count
      }
    end

    def revenue_stats
      {
        mrr: calculate_mrr,
        subscriptions_active: Subscription.active.count,
        payments_this_month: Payment.where("created_at >= ?", Time.current.beginning_of_month).sum(:amount_cents) / 100.0,
        donations_this_month: Donation.where("created_at >= ?", Time.current.beginning_of_month).sum(:amount_cents) / 100.0
      }
    end

    def calculate_mrr
      # Calculate Monthly Recurring Revenue from active subscriptions
      # Note: price_cents is the plan price; for monthly billing period it represents MRR
      Subscription.active.joins(:price_plan).sum("price_plans.price_cents") / 100.0
    end
  end
end
