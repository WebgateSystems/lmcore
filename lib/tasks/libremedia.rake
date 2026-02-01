# frozen_string_literal: true

namespace :libremedia do
  desc "Setup the application (create database, migrate, seed)"
  task setup: :environment do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
    puts "LibreMedia setup complete!"
  end

  desc "Reset monthly post counts for all users (run on 1st of each month)"
  task reset_monthly_posts: :environment do
    User.update_all(posts_this_month: 0)
    puts "Reset posts_this_month for #{User.count} users"
  end

  desc "Expire old invitations"
  task expire_invitations: :environment do
    count = Invitation.pending.where("expires_at <= ?", Time.current).update_all(status: "expired")
    puts "Expired #{count} invitations"
  end

  desc "Publish scheduled content"
  task publish_scheduled: :environment do
    PublishScheduledContentWorker.new.perform
    puts "Published scheduled content"
  end

  desc "Cleanup old audit logs (older than 1 year)"
  task cleanup_audit_logs: :environment do
    count = AuditLog.where("created_at < ?", 1.year.ago).delete_all
    puts "Deleted #{count} old audit logs"
  end

  desc "Expire subscriptions"
  task expire_subscriptions: :environment do
    Subscription.active.where("expires_at < ?", Time.current).find_each do |subscription|
      subscription.expire!
      puts "Expired subscription #{subscription.id} for user #{subscription.user_id}"
    end
  end

  desc "Send subscription expiry reminders (7 days before)"
  task send_expiry_reminders: :environment do
    Subscription.expiring_soon.includes(:user).find_each do |subscription|
      # Create notification
      Notification.create!(
        user: subscription.user,
        notification_type: "subscription_expiring",
        data: { days_remaining: subscription.days_remaining }
      )
      puts "Sent expiry reminder for subscription #{subscription.id}"
    end
  end
end
