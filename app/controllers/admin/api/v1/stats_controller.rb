# frozen_string_literal: true

module Admin
  module Api
    module V1
      class StatsController < BaseController
        def index
          authorize :admin_dashboard, :index?

          render_success(
            {
              users: user_stats,
              content: content_stats,
              engagement: engagement_stats,
              revenue: revenue_stats,
              system: system_stats
            }
          )
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
            pending: User.pending.count,
            by_role: users_by_role,
            growth: user_growth_data
          }
        end

        def users_by_role
          User.joins(:role)
              .group("roles.name")
              .count
              .transform_keys(&:to_s)
        end

        def user_growth_data
          # Last 30 days user registrations
          (0..29).map do |days_ago|
            date = days_ago.days.ago.to_date
            {
              date: date.to_s,
              count: User.where(created_at: date.beginning_of_day..date.end_of_day).count
            }
          end.reverse
        end

        def content_stats
          {
            posts: {
              total: Post.count,
              published: Post.published.count,
              draft: Post.draft.count,
              archived: Post.archived.count
            },
            videos: {
              total: Video.count,
              published: Video.published.count,
              processing: Video.processing.count
            },
            photos: {
              total: Photo.count,
              published: Photo.published.count
            },
            pages: {
              total: Page.count,
              published: Page.published.count
            },
            comments: Comment.count,
            categories: Category.count,
            tags: Tag.count
          }
        end

        def engagement_stats
          today = Time.current.beginning_of_day
          this_week = 1.week.ago

          {
            comments: {
              total: Comment.count,
              today: Comment.where("created_at >= ?", today).count,
              this_week: Comment.where("created_at >= ?", this_week).count
            },
            reactions: {
              total: Reaction.count,
              today: Reaction.where("created_at >= ?", today).count,
              this_week: Reaction.where("created_at >= ?", this_week).count
            },
            follows: {
              total: Follow.count,
              today: Follow.where("created_at >= ?", today).count
            }
          }
        end

        def revenue_stats
          this_month = Time.current.beginning_of_month
          last_month = 1.month.ago.beginning_of_month..1.month.ago.end_of_month

          {
            mrr: calculate_mrr,
            subscriptions: {
              active: Subscription.active.count,
              total: Subscription.count
            },
            payments: {
              this_month: Payment.where("created_at >= ?", this_month).sum(:amount_cents) / 100.0,
              last_month: Payment.where(created_at: last_month).sum(:amount_cents) / 100.0,
              total: Payment.sum(:amount_cents) / 100.0
            },
            donations: {
              this_month: Donation.where("created_at >= ?", this_month).sum(:amount_cents) / 100.0,
              total: Donation.sum(:amount_cents) / 100.0
            }
          }
        end

        def system_stats
          {
            disk_usage: total_disk_usage,
            audit_logs: AuditLog.count,
            api_keys: ApiKey.active.count,
            version: AppIdService.version
          }
        end

        def calculate_mrr
          Subscription.active.joins(:price_plan).sum("price_plans.monthly_price_cents") / 100.0
        rescue StandardError
          0.0
        end

        def total_disk_usage
          User.sum(:disk_space_used_bytes)
        rescue StandardError
          0
        end
      end
    end
  end
end
