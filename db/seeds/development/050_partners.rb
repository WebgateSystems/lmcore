# frozen_string_literal: true

return unless Partner.count.zero?

log('Creating Partners...')

# Helper to create partner with translations
def create_partner(name:, slug:, descriptions:, url:, active: true, position: 0)
  partner = Partner.new(
    name: name,
    slug: slug,
    url: url,
    active: active,
    position: position
  )
  partner.description_i18n = descriptions
  partner.save!
  partner
end

create_partner(
  name: 'Ukrainian Veterans Foundation',
  slug: 'ukrainian-veterans-foundation',
  descriptions: {
    'en' => 'Supporting Ukrainian veterans and their families',
    'pl' => 'Wspieranie ukraińskich weteranów i ich rodzin',
    'uk' => 'Підтримка українських ветеранів та їхніх родин',
    'lt' => 'Ukrainos veteranų ir jų šeimų palaikymas'
  },
  url: 'https://example.org/uvf',
  position: 0
)

create_partner(
  name: 'Press Freedom Initiative',
  slug: 'press-freedom-initiative',
  descriptions: {
    'en' => 'Defending journalists and press freedom worldwide',
    'pl' => 'Obrona dziennikarzy i wolności prasy na całym świecie',
    'uk' => 'Захист журналістів та свободи преси у всьому світі',
    'lt' => 'Žurnalistų ir spaudos laisvės gynimas visame pasaulyje'
  },
  url: 'https://example.org/pfi',
  position: 1
)

create_partner(
  name: 'Digital Rights Foundation',
  slug: 'digital-rights-foundation',
  descriptions: {
    'en' => 'Protecting digital rights and online privacy',
    'pl' => 'Ochrona praw cyfrowych i prywatności online',
    'uk' => 'Захист цифрових прав та онлайн-приватності',
    'lt' => 'Skaitmeninių teisių ir privatumo internete apsauga'
  },
  url: 'https://example.org/drf',
  position: 2
)

create_partner(
  name: 'Independent Media Network',
  slug: 'independent-media-network',
  descriptions: {
    'en' => 'Network of independent media outlets',
    'pl' => 'Sieć niezależnych mediów',
    'uk' => 'Мережа незалежних ЗМІ',
    'lt' => 'Nepriklausomų žiniasklaidos priemonių tinklas'
  },
  url: 'https://example.org/imn',
  position: 3
)

log("Created #{Partner.count} partners")
