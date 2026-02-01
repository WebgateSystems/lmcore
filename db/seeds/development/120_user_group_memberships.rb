# frozen_string_literal: true

# Note: UserGroup's after_create callback already adds owner as admin
# We only add additional members here

return if UserGroupMembership.count > UserGroup.count # More memberships than just owners

log('Creating User Group Memberships...')

# Get user groups
group_verified = UserGroup.find_by(slug: 'verified-authors')
group_journalists = UserGroup.find_by(slug: 'journalists')
group_opinion_leaders = UserGroup.find_by(slug: 'opinion-leaders')
group_beta_testers = UserGroup.find_by(slug: 'beta-testers')

# Get users
admin = User.find_by(username: 'admin')
author_pl = User.find_by(username: 'jan_kowalski')
author_uk = User.find_by(username: 'olena_shevchenko')
author_lt = User.find_by(username: 'jonas_kazlauskas')

# Add admin to beta testers (if not already owner)
if admin && group_beta_testers && group_beta_testers.owner != admin
  group_beta_testers.add_member(admin, role: 'member')
end

# Add authors to verified authors group
if group_verified
  [ author_pl, author_uk, author_lt ].compact.each do |author|
    next if author == group_verified.owner

    group_verified.add_member(author, role: 'member')
  end
end

# Add authors to journalists group
if group_journalists
  [ author_pl, author_uk, author_lt ].compact.each do |author|
    next if author == group_journalists.owner

    group_journalists.add_member(author, role: 'member')
  end
end

# Add one author as opinion leader
if author_pl && group_opinion_leaders && author_pl != group_opinion_leaders.owner
  group_opinion_leaders.add_member(author_pl, role: 'member')
end

log("Created #{UserGroupMembership.count} user group memberships (including owner memberships)")
