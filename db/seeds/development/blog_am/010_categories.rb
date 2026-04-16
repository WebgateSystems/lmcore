# frozen_string_literal: true

ayder = User.find_by!(email: 'ayder@gmail.com')
return if ayder.categories.exists?

log('  [Blog AM] Creating categories...')

categories_data = [
  {
    slug: 'politics',
    name_i18n: { 'en' => 'Politics', 'uk' => 'Політика', 'ru' => 'Политика', 'pl' => 'Polityka' },
    description_i18n: { 'en' => 'Political news and analysis', 'uk' => 'Політичні новини та аналітика', 'ru' => 'Политические новости и аналитика', 'pl' => 'Wiadomości polityczne i analizy' },
    category_type: 'posts'
  },
  {
    slug: 'crimea',
    name_i18n: { 'en' => 'Crimea', 'uk' => 'Крим', 'ru' => 'Крым', 'pl' => 'Krym' },
    description_i18n: { 'en' => 'News about Crimea', 'uk' => 'Новини про Крим', 'ru' => 'Новости о Крыме', 'pl' => 'Wiadomości o Krymie' },
    category_type: 'general'
  },
  {
    slug: 'ukraine',
    name_i18n: { 'en' => 'Ukraine', 'uk' => 'Україна', 'ru' => 'Украина', 'pl' => 'Ukraina' },
    description_i18n: { 'en' => 'News about Ukraine', 'uk' => 'Новини про Україну', 'ru' => 'Новости об Украине', 'pl' => 'Wiadomości o Ukrainie' },
    category_type: 'general'
  },
  {
    slug: 'media',
    name_i18n: { 'en' => 'Media', 'uk' => 'Медіа', 'ru' => 'Медиа', 'pl' => 'Media' },
    description_i18n: { 'en' => 'Media and journalism', 'uk' => 'Медіа та журналістика', 'ru' => 'Медиа и журналистика', 'pl' => 'Media i dziennikarstwo' },
    category_type: 'videos'
  }
]

categories_data.each do |data|
  cat = ayder.categories.new(
    slug: data[:slug],
    category_type: data[:category_type]
  )
  cat.name_i18n = data[:name_i18n]
  cat.description_i18n = data[:description_i18n]
  cat.save!
end

log("  [Blog AM] Created #{ayder.categories.count} categories")
