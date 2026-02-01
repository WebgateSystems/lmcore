# frozen_string_literal: true

return if User.joins(:role).where(roles: { slug: %w[super-admin admin] }).exists?

log('Creating Users...')

pwd = 'devpass123!'

# Get roles
@role_super_admin = Role.find_by!(slug: 'super-admin')
@role_admin = Role.find_by!(slug: 'admin')
@role_moderator = Role.find_by!(slug: 'moderator')
@role_editor = Role.find_by!(slug: 'editor')
@role_author = Role.find_by!(slug: 'author')
@role_user = Role.find_by!(slug: 'user')

# Get price plans
@plan_enterprise = PricePlan.find_by!(slug: 'enterprise')
@plan_professional = PricePlan.find_by!(slug: 'professional')
@plan_basic = PricePlan.find_by!(slug: 'basic')
@plan_free = PricePlan.find_by!(slug: 'free')

# Super Admin
@super_admin = User.create!(
  email: 'superadmin@libremedia.org',
  password: pwd,
  password_confirmation: pwd,
  username: 'superadmin',
  first_name: 'Super',
  last_name: 'Admin',
  bio: 'Platform super administrator',
  locale: 'en',
  status: 'active',
  confirmed_at: Time.current,
  role: @role_super_admin,
  price_plan: @plan_enterprise,
  phone: "+48#{rand(500_000_000..599_999_999)}"
)
log("  Created super admin: #{@super_admin.email}")

# Admin
@admin = User.create!(
  email: 'admin@libremedia.org',
  password: pwd,
  password_confirmation: pwd,
  username: 'admin',
  first_name: 'Admin',
  last_name: 'User',
  bio: 'Platform administrator',
  locale: 'en',
  status: 'active',
  confirmed_at: Time.current,
  role: @role_admin,
  price_plan: @plan_enterprise,
  phone: "+48#{rand(600_000_000..699_999_999)}"
)
log("  Created admin: #{@admin.email}")

# Moderator
@moderator = User.create!(
  email: 'moderator@libremedia.org',
  password: pwd,
  password_confirmation: pwd,
  username: 'moderator',
  first_name: 'Maria',
  last_name: 'Moderator',
  bio: 'Content moderator',
  locale: 'pl',
  status: 'active',
  confirmed_at: Time.current,
  role: @role_moderator,
  price_plan: @plan_professional,
  phone: "+48#{rand(700_000_000..799_999_999)}"
)
log("  Created moderator: #{@moderator.email}")

# Editor
@editor = User.create!(
  email: 'editor@libremedia.org',
  password: pwd,
  password_confirmation: pwd,
  username: 'editor',
  first_name: 'Edward',
  last_name: 'Editor',
  bio: 'Content editor and curator',
  locale: 'en',
  status: 'active',
  confirmed_at: Time.current,
  role: @role_editor,
  price_plan: @plan_professional,
  phone: "+48#{rand(800_000_000..899_999_999)}"
)
log("  Created editor: #{@editor.email}")

# Sample Author - Polish journalist
@author_pl = User.create!(
  email: 'autor@libremedia.org',
  password: pwd,
  password_confirmation: pwd,
  username: 'jan_kowalski',
  first_name: 'Jan',
  last_name: 'Kowalski',
  bio: 'Niezależny dziennikarz i publicysta. Piszę o polityce, społeczeństwie i wolności słowa.',
  locale: 'pl',
  status: 'active',
  confirmed_at: Time.current,
  role: @role_author,
  price_plan: @plan_professional,
  phone: "+48#{rand(500_000_000..599_999_999)}"
)
log("  Created author (PL): #{@author_pl.email}")

# Sample Author - Ukrainian journalist
@author_uk = User.create!(
  email: 'author.ua@libremedia.org',
  password: pwd,
  password_confirmation: pwd,
  username: 'olena_shevchenko',
  first_name: 'Олена',
  last_name: 'Шевченко',
  bio: 'Журналістка та блогерка. Пишу про війну, правду та людей.',
  locale: 'uk',
  status: 'active',
  confirmed_at: Time.current,
  role: @role_author,
  price_plan: @plan_professional,
  phone: "+380#{rand(50_000_0000..99_999_9999)}"
)
log("  Created author (UK): #{@author_uk.email}")

# Sample Author - Lithuanian journalist
@author_lt = User.create!(
  email: 'author.lt@libremedia.org',
  password: pwd,
  password_confirmation: pwd,
  username: 'jonas_kazlauskas',
  first_name: 'Jonas',
  last_name: 'Kazlauskas',
  bio: 'Nepriklausomas žurnalistas. Rašau apie politiką ir visuomenę.',
  locale: 'lt',
  status: 'active',
  confirmed_at: Time.current,
  role: @role_author,
  price_plan: @plan_basic,
  phone: "+370#{rand(600_00000..699_99999)}"
)
log("  Created author (LT): #{@author_lt.email}")

# Sample regular users
5.times do |i|
  User.create!(
    email: "user#{i + 1}@libremedia.org",
    password: pwd,
    password_confirmation: pwd,
    username: "user#{i + 1}",
    first_name: "User",
    last_name: "#{i + 1}",
    bio: "Regular platform user ##{i + 1}",
    locale: %w[en pl uk lt].sample,
    status: 'active',
    confirmed_at: Time.current,
    role: @role_user,
    price_plan: @plan_free,
    phone: "+48#{rand(500_000_000..999_999_999)}"
  )
end
log("  Created 5 regular users")

log("Created #{User.count} users total")
log("  Credentials for all dev users: password = '#{pwd}'")
