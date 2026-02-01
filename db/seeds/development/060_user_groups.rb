# frozen_string_literal: true

return unless UserGroup.count.zero?

log('Creating User Groups...')

# We need a user to own the groups - use admin
@admin_user = User.find_by(username: 'admin') || User.first

unless @admin_user
  log('  Skipping user groups - no users exist yet. Run seeds again after users are created.')
  return
end

# Helper to create user group with translations
def create_user_group(owner:, name:, slug:, descriptions:, visibility: 'public')
  group = UserGroup.new(
    owner: owner,
    name: name,
    slug: slug,
    visibility: visibility
  )
  group.description_i18n = descriptions
  group.save!
  group
end

# Public groups
@group_verified = create_user_group(
  owner: @admin_user,
  name: 'Verified Authors',
  slug: 'verified-authors',
  descriptions: {
    'en' => 'Verified content creators with established reputation',
    'pl' => 'Zweryfikowani twórcy treści z ugruntowaną reputacją',
    'uk' => 'Верифіковані творці контенту з усталеною репутацією',
    'lt' => 'Patikrinti turinio kūrėjai su nusistovėjusia reputacija'
  },
  visibility: 'public'
)

@group_journalists = create_user_group(
  owner: @admin_user,
  name: 'Journalists',
  slug: 'journalists',
  descriptions: {
    'en' => 'Professional journalists and reporters',
    'pl' => 'Profesjonalni dziennikarze i reporterzy',
    'uk' => 'Професійні журналісти та репортери',
    'lt' => 'Profesionalūs žurnalistai ir reporteriai'
  },
  visibility: 'public'
)

@group_veterans = create_user_group(
  owner: @admin_user,
  name: 'Veterans',
  slug: 'veterans',
  descriptions: {
    'en' => 'Military veterans community',
    'pl' => 'Społeczność weteranów wojskowych',
    'uk' => 'Спільнота військових ветеранів',
    'lt' => 'Karo veteranų bendruomenė'
  },
  visibility: 'public'
)

@group_opinion_leaders = create_user_group(
  owner: @admin_user,
  name: 'Opinion Leaders',
  slug: 'opinion-leaders',
  descriptions: {
    'en' => 'Public opinion leaders with impeccable reputation',
    'pl' => 'Liderzy opinii publicznej z nieskazitelną reputacją',
    'uk' => 'Лідери громадської думки з бездоганною репутацією',
    'lt' => 'Visuomenės nuomonės lyderiai su nepriekaištinga reputacija'
  },
  visibility: 'private'
)

@group_beta_testers = create_user_group(
  owner: @admin_user,
  name: 'Beta Testers',
  slug: 'beta-testers',
  descriptions: {
    'en' => 'Early access to new features',
    'pl' => 'Wczesny dostęp do nowych funkcji',
    'uk' => 'Ранній доступ до нових функцій',
    'lt' => 'Ankstyvesnė prieiga prie naujų funkcijų'
  },
  visibility: 'private'
)

log("Created #{UserGroup.count} user groups")
