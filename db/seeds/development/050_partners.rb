# frozen_string_literal: true

return unless Partner.count.zero?

log('Creating Media Partners...')

# Helper to create partner with translations
def create_media_partner(name:, slug:, description:, url:, icon_class:, locale:, active: true, position: 0)
  Partner.create!(
    name: name,
    slug: slug,
    url: url,
    icon_class: icon_class,
    locale: locale,
    active: active,
    position: position,
    description_i18n: { locale => description }
  )
end

# ============================================
# POLISH PARTNERS (locale: 'pl')
# ============================================
POLISH_PARTNERS = [
  {
    name: 'checkPRESS.pl',
    slug: 'checkpress',
    icon_class: 'fa-solid fa-newspaper',
    url: 'https://checkpress.pl/',
    description: 'Niezależny portal polityczny i społeczny'
  },
  {
    name: 'Radio Rebeliant',
    slug: 'radiorebeliant',
    icon_class: 'fa-solid fa-microphone',
    url: 'https://radiorebeliant.pl/',
    description: 'Społeczne radio internetowe'
  },
  {
    name: 'Tomasz Lis',
    slug: 'tomasz-lis',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@TomaszLisOfficial',
    description: 'Dziennikarz, publicysta, były red. nacz. Newsweeka'
  },
  {
    name: 'Jan Piński',
    slug: 'jan-pinski',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@Jan_Pinski',
    description: 'Dziennikarz śledczy, publicysta'
  },
  {
    name: 'Tomasz Wiejski',
    slug: 'tomasz-wiejski',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@okiemwiejskiego',
    description: 'Komentator polityczny, kanał Okiem Wiejskiego'
  },
  {
    name: 'Sebastian Owczarski',
    slug: 'sebastian-owczarski',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@Seb-O',
    description: 'Dziennikarz i publicysta'
  },
  {
    name: 'Tomasz Szwejgiert',
    slug: 'tomasz-szwejgiert',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@TomaszSzwejgiert',
    description: 'Dziennikarz i lider opinii publicznej'
  },
  {
    name: 'Jerzy Sładkowski',
    slug: 'jerzy-sladkowski-pl',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@Jerzy_Sladkowski',
    description: 'Twórca LibreMedia, niezależny publicysta, filozof'
  }
].freeze

# ============================================
# UKRAINIAN PARTNERS (locale: 'uk')
# ============================================
UKRAINIAN_PARTNERS = [
  {
    name: 'Українська правда',
    slug: 'ukrayinska-pravda',
    icon_class: 'fa-solid fa-newspaper',
    url: 'https://www.pravda.com.ua/',
    description: 'Провідне українське інтернет-видання'
  },
  {
    name: 'ATR',
    slug: 'atr',
    icon_class: 'fa-solid fa-tv',
    url: 'https://atr.ua/',
    description: 'Перший кримськотатарський телеканал'
  },
  {
    name: 'Віталій Портніков',
    slug: 'vitaliy-portnikov',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@portnikov',
    description: 'Український журналіст, публіцист, політичний оглядач'
  },
  {
    name: 'Александр Невзоров',
    slug: 'aleksandr-nevzorov',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/channel/UC8kI2B-UUv7A5u3AOUnHNMQ',
    description: 'Російський опозиційний журналіст, публіцист'
  },
  {
    name: 'Айдер Муждабаєв',
    slug: 'ayder-muzhdabaev',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/channel/UCo1D6QXPYxlreDFS8FtAc4Q',
    description: 'Український журналіст, політичний коментатор'
  },
  {
    name: 'Аркадій Бабченко',
    slug: 'arkadiy-babchenko',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@starshinazapasa',
    description: 'Російський опозиційний журналіст в еміграції'
  },
  {
    name: 'Яніна Соколова',
    slug: 'yanina-sokolova',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/user/YaninaSokolova',
    description: 'Українська журналістка, телеведуча'
  },
  {
    name: 'Jerzy Sładkowski',
    slug: 'jerzy-sladkowski-uk',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@Jerzy_Sladkowski',
    description: 'Засновник LibreMedia, незалежний публіцист, філософ'
  }
].freeze

# ============================================
# ENGLISH PARTNERS (locale: 'en')
# Democratic, pro-freedom journalists and outlets
# ============================================
ENGLISH_PARTNERS = [
  {
    name: 'The Guardian',
    slug: 'the-guardian',
    icon_class: 'fa-solid fa-newspaper',
    url: 'https://www.theguardian.com/',
    description: 'Independent British newspaper with global reach'
  },
  {
    name: 'The Daily Show',
    slug: 'the-daily-show',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/thedailyshow',
    description: 'Emmy-winning satirical news program with Jon Stewart'
  },
  {
    name: 'Jimmy Kimmel Live',
    slug: 'jimmy-kimmel-live',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/jimmykimmellive',
    description: 'Late-night talk show with political commentary'
  },
  {
    name: 'Mehdi Hasan',
    slug: 'mehdi-hasan',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@meaboringshow',
    description: 'Award-winning journalist and political commentator'
  },
  {
    name: 'Brian Tyler Cohen',
    slug: 'brian-tyler-cohen',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@briantylercohen',
    description: 'Political commentator and progressive voice'
  },
  {
    name: 'Pod Save America',
    slug: 'pod-save-america',
    icon_class: 'fa-solid fa-podcast',
    url: 'https://crooked.com/podcast-series/pod-save-america/',
    description: 'Progressive political podcast by former Obama staffers'
  },
  {
    name: 'Dan Rather',
    slug: 'dan-rather',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@DanRather',
    description: 'Legendary journalist, anchor and author'
  },
  {
    name: 'Jerzy Sładkowski',
    slug: 'jerzy-sladkowski-en',
    icon_class: 'fa-brands fa-youtube',
    url: 'https://www.youtube.com/@Jerzy_Sladkowski',
    description: 'LibreMedia founder, independent publicist, philosopher'
  }
].freeze

# Create all partners
position = 0

POLISH_PARTNERS.each do |partner_data|
  create_media_partner(
    name: partner_data[:name],
    slug: partner_data[:slug],
    description: partner_data[:description],
    url: partner_data[:url],
    icon_class: partner_data[:icon_class],
    locale: 'pl',
    position: position
  )
  position += 1
end

UKRAINIAN_PARTNERS.each do |partner_data|
  create_media_partner(
    name: partner_data[:name],
    slug: partner_data[:slug],
    description: partner_data[:description],
    url: partner_data[:url],
    icon_class: partner_data[:icon_class],
    locale: 'uk',
    position: position
  )
  position += 1
end

ENGLISH_PARTNERS.each do |partner_data|
  create_media_partner(
    name: partner_data[:name],
    slug: partner_data[:slug],
    description: partner_data[:description],
    url: partner_data[:url],
    icon_class: partner_data[:icon_class],
    locale: 'en',
    position: position
  )
  position += 1
end

log("Created #{Partner.count} media partners (PL: #{Partner.where(locale: 'pl').count}, UK: #{Partner.where(locale: 'uk').count}, EN: #{Partner.where(locale: 'en').count})")
