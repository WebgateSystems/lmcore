# frozen_string_literal: true

module Dashboard
  class AudienceController < BaseController
    def index
      authorize :audience, policy_class: Dashboard::AudiencePolicy

      @query = params[:q].to_s.strip
      @commenters = commenters_scope
      @subscribers = subscribers_scope

      @pagy_commenters, @commenters = pagy(@commenters, items: 20, page_param: :commenters_page)
      @pagy_subscribers, @subscribers = pagy(@subscribers, items: 20, page_param: :subscribers_page)

      load_bans_by_user_id
      load_trusted_commenters_by_user_id
    end

    def ban
      authorize :audience, policy_class: Dashboard::AudiencePolicy

      target_user = User.find(params.require(:user_id))
      ban = BlogBan.find_or_initialize_by(blog_owner: dashboard_blog_user, user: target_user)
      ban.banned_by = current_user
      ban.reason = params.require(:reason).to_s.strip
      ban.active = true
      ban.permanent = true

      if ban.save
        redirect_to dashboard_audience_index_path(q: params[:q]), notice: t("dashboard.flash.audience.banned", default: "User has been permanently banned from this blog.")
      else
        redirect_to dashboard_audience_index_path(q: params[:q]), alert: ban.errors.full_messages.to_sentence
      end
    end

    def trust
      authorize :audience, policy_class: Dashboard::AudiencePolicy

      target_user = User.find(params.require(:user_id))
      trusted = BlogTrustedCommenter.find_or_initialize_by(blog_owner: dashboard_blog_user, user: target_user)
      trusted.granted_by = current_user

      if trusted.save
        redirect_to dashboard_audience_index_path(q: params[:q]), notice: t("dashboard.flash.audience.trusted", default: "User can now comment without premoderation.")
      else
        redirect_to dashboard_audience_index_path(q: params[:q]), alert: trusted.errors.full_messages.to_sentence
      end
    end

    def untrust
      authorize :audience, policy_class: Dashboard::AudiencePolicy

      trusted = BlogTrustedCommenter.find_by!(blog_owner: dashboard_blog_user, user_id: params.require(:user_id))
      trusted.destroy!
      redirect_to dashboard_audience_index_path(q: params[:q]), notice: t("dashboard.flash.audience.untrusted", default: "Trusted commenter permission has been revoked.")
    end

    private

    def commenters_scope
      comments_scope = policy_scope(Comment, policy_scope_class: Dashboard::CommentPolicy::Scope).where.not(user_id: nil)
      comments_scope = comments_scope.includes(:user)

      grouped = comments_scope.group(:user_id).select("comments.user_id AS user_id, COUNT(*) AS comments_count, MAX(comments.created_at) AS last_commented_at")

      scope = User.joins("INNER JOIN (#{grouped.to_sql}) commenter_stats ON commenter_stats.user_id = users.id")
                  .select("users.*, commenter_stats.comments_count, commenter_stats.last_commented_at")
                  .order("commenter_stats.last_commented_at DESC")

      apply_user_search(scope)
    end

    def subscribers_scope
      scope = User.joins(:newsletter_subscriptions)
                  .where(newsletter_subscriptions: { blog_owner_id: dashboard_blog_user.id })
                  .select("users.*, MAX(newsletter_subscriptions.created_at) AS subscribed_at")
                  .group("users.id")
                  .order(Arel.sql("MAX(newsletter_subscriptions.created_at) DESC"))

      apply_user_search(scope)
    end

    def apply_user_search(scope)
      return scope if @query.blank?

      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
      scope.where(
        "users.email ILIKE :q OR users.username ILIKE :q OR users.first_name ILIKE :q OR users.last_name ILIKE :q",
        q: pattern
      )
    end

    def load_bans_by_user_id
      user_ids = (@commenters.map(&:id) + @subscribers.map(&:id)).uniq
      @bans_by_user_id = BlogBan.active.for_blog(dashboard_blog_user).where(user_id: user_ids).index_by(&:user_id)
    end

    def load_trusted_commenters_by_user_id
      user_ids = (@commenters.map(&:id) + @subscribers.map(&:id)).uniq
      @trusted_commenters_by_user_id = BlogTrustedCommenter.for_blog(dashboard_blog_user).where(user_id: user_ids).index_by(&:user_id)
    end
  end
end
