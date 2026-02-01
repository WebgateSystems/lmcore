# frozen_string_literal: true

return if Subscription.exists?

log('Creating Subscriptions...')

# Get users with paid plans
enterprise_users = User.joins(:price_plan).where(price_plans: { slug: 'enterprise' })
professional_users = User.joins(:price_plan).where(price_plans: { slug: 'professional' })
basic_users = User.joins(:price_plan).where(price_plans: { slug: 'basic' })

# Create active subscriptions for enterprise users
enterprise_users.each do |user|
  Subscription.create!(
    user: user,
    price_plan: user.price_plan,
    status: 'active',
    started_at: 1.month.ago,
    expires_at: 11.months.from_now,
    auto_renew: true
  )
end

# Create active subscriptions for professional users
professional_users.each do |user|
  Subscription.create!(
    user: user,
    price_plan: user.price_plan,
    status: 'active',
    started_at: 2.weeks.ago,
    expires_at: 11.months.from_now + 2.weeks,
    auto_renew: true
  )
end

# Create active subscriptions for basic users
basic_users.each do |user|
  Subscription.create!(
    user: user,
    price_plan: user.price_plan,
    status: 'active',
    started_at: 1.week.ago,
    expires_at: 11.months.from_now + 3.weeks,
    auto_renew: false
  )
end

log("Created #{Subscription.count} subscriptions")
