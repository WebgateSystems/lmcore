# frozen_string_literal: true

return unless Role.count.zero?

log('Creating Roles...')

[
  {
    name: 'Super Admin',
    slug: 'super-admin',
    name_i18n: { 'en' => 'Super Admin', 'pl' => 'Super Administrator', 'uk' => 'Супер Адміністратор', 'lt' => 'Super Administratorius' },
    permissions: [ '*' ],
    priority: 100,
    system_role: true
  },
  {
    name: 'Admin',
    slug: 'admin',
    name_i18n: { 'en' => 'Admin', 'pl' => 'Administrator', 'uk' => 'Адміністратор', 'lt' => 'Administratorius' },
    permissions: %w[manage_users manage_content manage_settings moderate_comments view_analytics],
    priority: 90,
    system_role: true
  },
  {
    name: 'Moderator',
    slug: 'moderator',
    name_i18n: { 'en' => 'Moderator', 'pl' => 'Moderator', 'uk' => 'Модератор', 'lt' => 'Moderatorius' },
    permissions: %w[moderate_comments moderate_content view_reports ban_users],
    priority: 50,
    system_role: true
  },
  {
    name: 'Editor',
    slug: 'editor',
    name_i18n: { 'en' => 'Editor', 'pl' => 'Redaktor', 'uk' => 'Редактор', 'lt' => 'Redaktorius' },
    permissions: %w[create_content edit_content delete_content manage_categories manage_tags],
    priority: 40,
    system_role: true
  },
  {
    name: 'Author',
    slug: 'author',
    name_i18n: { 'en' => 'Author', 'pl' => 'Autor', 'uk' => 'Автор', 'lt' => 'Autorius' },
    permissions: %w[create_content edit_own_content delete_own_content],
    priority: 30,
    system_role: true
  },
  {
    name: 'Contributor',
    slug: 'contributor',
    name_i18n: { 'en' => 'Contributor', 'pl' => 'Współtwórca', 'uk' => 'Співавтор', 'lt' => 'Bendradarbis' },
    permissions: %w[create_content edit_own_content],
    priority: 20,
    system_role: true
  },
  {
    name: 'User',
    slug: 'user',
    name_i18n: { 'en' => 'User', 'pl' => 'Użytkownik', 'uk' => 'Користувач', 'lt' => 'Vartotojas' },
    permissions: %w[comment react follow read_content],
    priority: 10,
    system_role: true
  }
].each do |data|
  role = Role.new(data.except(:name, :name_i18n))
  role.write_attribute(:name, data[:name])
  role.name_i18n = data[:name_i18n]
  role.save!
end

log("Created #{Role.count} roles")
