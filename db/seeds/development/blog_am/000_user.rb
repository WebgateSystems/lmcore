# frozen_string_literal: true

return if User.find_by(email: 'ayder@gmail.com')

log('  [Blog AM] Creating Ayder Muzhdabaev user...')

pwd = 'devpass123!'
author_role = Role.find_by!(slug: 'author')
plan = PricePlan.find_by(slug: 'professional') || PricePlan.first

ayder = User.create!(
  email: 'ayder@gmail.com',
  password: pwd,
  password_confirmation: pwd,
  username: 'am',
  first_name: 'Айдер',
  last_name: 'Муждабаєв',
  display_name: 'Ayder Muzhdabaev',
  display_name_i18n: {
    en: 'Ayder Muzhdabaiev',
    uk: 'Айдер Муждабаєв',
    ru: 'Айдер Муждабаев',
    pl: 'Ajder Mużdabajew'
  },
  bio: 'Журналіст, правозахисник, генеральний директор телеканалу ATR',
  locale: 'uk',
  status: 'active',
  confirmed_at: Time.current,
  price_plan: plan,
  vanity_domain: 'am.libremedia.org'
)

ayder.assign_role!(author_role)

log("  [Blog AM] Created user: #{ayder.email} (username: #{ayder.username})")
