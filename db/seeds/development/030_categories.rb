# frozen_string_literal: true

return unless Category.count.zero?

log('Creating Categories...')

# We need a user to own the categories - use admin
# Categories will be created after users in a real scenario,
# but for dev seeds we'll create a system user first if needed
@system_user = User.find_by(username: 'admin') || User.first

unless @system_user
  log('  Skipping categories - no users exist yet. Run seeds again after users are created.')
  return
end

# Helper to create category with translations
def create_category(user:, slug:, names:, descriptions: nil, parent: nil, position: 0, category_type: 'general')
  cat = Category.new(
    user: user,
    slug: slug,
    parent: parent,
    position: position,
    category_type: category_type
  )
  cat.name_i18n = names
  cat.description_i18n = descriptions if descriptions
  cat.save!
  cat
end

# Main categories
@cat_news = create_category(
  user: @system_user,
  slug: 'news',
  names: { 'en' => 'News', 'pl' => 'Aktualności', 'uk' => 'Новини', 'lt' => 'Naujienos' },
  descriptions: {
    'en' => 'Latest news and current events',
    'pl' => 'Najnowsze wiadomości i bieżące wydarzenia',
    'uk' => 'Останні новини та поточні події',
    'lt' => 'Naujausi įvykiai ir aktualijos'
  },
  position: 0,
  category_type: 'posts'
)

@cat_politics = create_category(
  user: @system_user,
  slug: 'politics',
  names: { 'en' => 'Politics', 'pl' => 'Polityka', 'uk' => 'Політика', 'lt' => 'Politika' },
  descriptions: {
    'en' => 'Political analysis and commentary',
    'pl' => 'Analiza polityczna i komentarze',
    'uk' => 'Політичний аналіз та коментарі',
    'lt' => 'Politinė analizė ir komentarai'
  },
  position: 1,
  category_type: 'posts'
)

@cat_technology = create_category(
  user: @system_user,
  slug: 'technology',
  names: { 'en' => 'Technology', 'pl' => 'Technologia', 'uk' => 'Технології', 'lt' => 'Technologijos' },
  descriptions: {
    'en' => 'Technology news and reviews',
    'pl' => 'Wiadomości technologiczne i recenzje',
    'uk' => 'Технологічні новини та огляди',
    'lt' => 'Technologijų naujienos ir apžvalgos'
  },
  position: 2,
  category_type: 'posts'
)

@cat_culture = create_category(
  user: @system_user,
  slug: 'culture',
  names: { 'en' => 'Culture', 'pl' => 'Kultura', 'uk' => 'Культура', 'lt' => 'Kultūra' },
  descriptions: {
    'en' => 'Art, music, literature and entertainment',
    'pl' => 'Sztuka, muzyka, literatura i rozrywka',
    'uk' => 'Мистецтво, музика, література та розваги',
    'lt' => 'Menas, muzika, literatūra ir pramogos'
  },
  position: 3,
  category_type: 'posts'
)

@cat_society = create_category(
  user: @system_user,
  slug: 'society',
  names: { 'en' => 'Society', 'pl' => 'Społeczeństwo', 'uk' => 'Суспільство', 'lt' => 'Visuomenė' },
  descriptions: {
    'en' => 'Social issues and human interest stories',
    'pl' => 'Kwestie społeczne i historie ludzkie',
    'uk' => 'Соціальні питання та історії про людей',
    'lt' => 'Socialinės problemos ir žmogiškosios istorijos'
  },
  position: 4,
  category_type: 'posts'
)

@cat_opinion = create_category(
  user: @system_user,
  slug: 'opinion',
  names: { 'en' => 'Opinion', 'pl' => 'Opinie', 'uk' => 'Думки', 'lt' => 'Nuomonė' },
  descriptions: {
    'en' => 'Editorial and opinion pieces',
    'pl' => 'Artykuły redakcyjne i opinie',
    'uk' => 'Редакційні та авторські матеріали',
    'lt' => 'Redakciniai ir nuomonių straipsniai'
  },
  position: 5,
  category_type: 'posts'
)

# Subcategories for Politics
create_category(
  user: @system_user,
  slug: 'domestic-politics',
  names: { 'en' => 'Domestic Politics', 'pl' => 'Polityka wewnętrzna', 'uk' => 'Внутрішня політика', 'lt' => 'Vidaus politika' },
  parent: @cat_politics,
  position: 0,
  category_type: 'posts'
)

create_category(
  user: @system_user,
  slug: 'international-politics',
  names: { 'en' => 'International Politics', 'pl' => 'Polityka międzynarodowa', 'uk' => 'Міжнародна політика', 'lt' => 'Tarptautinė politika' },
  parent: @cat_politics,
  position: 1,
  category_type: 'posts'
)

create_category(
  user: @system_user,
  slug: 'war-in-ukraine',
  names: { 'en' => 'War in Ukraine', 'pl' => 'Wojna w Ukrainie', 'uk' => 'Війна в Україні', 'lt' => 'Karas Ukrainoje' },
  parent: @cat_politics,
  position: 2,
  category_type: 'posts'
)

# Subcategories for Technology
create_category(
  user: @system_user,
  slug: 'cybersecurity',
  names: { 'en' => 'Cybersecurity', 'pl' => 'Cyberbezpieczeństwo', 'uk' => 'Кібербезпека', 'lt' => 'Kibernetinis saugumas' },
  parent: @cat_technology,
  position: 0,
  category_type: 'posts'
)

create_category(
  user: @system_user,
  slug: 'ai-ml',
  names: { 'en' => 'AI & Machine Learning', 'pl' => 'AI i uczenie maszynowe', 'uk' => 'ШІ та машинне навчання', 'lt' => 'DI ir mašininis mokymasis' },
  parent: @cat_technology,
  position: 1,
  category_type: 'posts'
)

create_category(
  user: @system_user,
  slug: 'digital-freedom',
  names: { 'en' => 'Digital Freedom', 'pl' => 'Wolność cyfrowa', 'uk' => 'Цифрова свобода', 'lt' => 'Skaitmeninė laisvė' },
  parent: @cat_technology,
  position: 2,
  category_type: 'posts'
)

# Subcategories for Culture
create_category(
  user: @system_user,
  slug: 'books',
  names: { 'en' => 'Books', 'pl' => 'Książki', 'uk' => 'Книги', 'lt' => 'Knygos' },
  parent: @cat_culture,
  position: 0,
  category_type: 'posts'
)

create_category(
  user: @system_user,
  slug: 'film',
  names: { 'en' => 'Film', 'pl' => 'Film', 'uk' => 'Кіно', 'lt' => 'Kinas' },
  parent: @cat_culture,
  position: 1,
  category_type: 'posts'
)

create_category(
  user: @system_user,
  slug: 'music',
  names: { 'en' => 'Music', 'pl' => 'Muzyka', 'uk' => 'Музика', 'lt' => 'Muzika' },
  parent: @cat_culture,
  position: 2,
  category_type: 'posts'
)

log("Created #{Category.count} categories")
