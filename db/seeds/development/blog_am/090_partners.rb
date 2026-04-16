# frozen_string_literal: true

log('  Creating Blog AM partners...')

partners_data = [
  {
    name: "LibreMedia",
    slug: "libremedia-am",
    url: "https://libremedia.org",
    logo_svg: '<svg width="110" height="50" viewBox="0 0 110 50" fill="none" xmlns="http://www.w3.org/2000/svg"><text x="5" y="35" font-family="Arial Black" font-size="24" fill="white">LIBRE</text><text x="5" y="48" font-family="Arial" font-size="10" fill="white">MEDIA</text></svg>',
    description: {
      "en" => "LibreMedia is a global platform for free and independent journalism.",
      "uk" => "LibreMedia — це глобальна платформа для вільної та незалежної журналістики.",
      "ru" => "LibreMedia — глобальная платформа для свободной и независимой журналистики.",
      "pl" => "LibreMedia to globalna platforma dla wolnego i niezależnego dziennikarstwa."
    },
    position: 100
  },
  {
    name: "BBC",
    slug: "bbc-am",
    url: "https://www.bbc.com",
    logo_svg: '<svg width="110" height="50" viewBox="0 0 110 50" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="5" y="10" width="30" height="30" fill="white"/><rect x="40" y="10" width="30" height="30" fill="white"/><rect x="75" y="10" width="30" height="30" fill="white"/><text x="12" y="32" font-family="Arial Black" font-size="20" fill="black">B</text><text x="47" y="32" font-family="Arial Black" font-size="20" fill="black">B</text><text x="82" y="32" font-family="Arial Black" font-size="20" fill="black">C</text></svg>',
    description: {
      "en" => "The British Broadcasting Corporation (BBC) is the national broadcaster of the United Kingdom.",
      "uk" => "Британська телерадіомовна корпорація (BBC) — національний мовник Великої Британії.",
      "ru" => "Британская вещательная корпорация (BBC) — национальный вещатель Великобритании.",
      "pl" => "British Broadcasting Corporation (BBC) to narodowy nadawca Wielkiej Brytanii."
    },
    position: 101
  },
  {
    name: "CNN",
    slug: "cnn-am",
    url: "https://www.cnn.com",
    logo_svg: '<svg width="110" height="50" viewBox="0 0 110 50" fill="none" xmlns="http://www.w3.org/2000/svg"><text x="10" y="38" font-family="Arial Black" font-size="32" fill="#CC0000">CNN</text></svg>',
    description: {
      "en" => "Cable News Network (CNN) is a multinational news channel and website.",
      "uk" => "Cable News Network (CNN) — це міжнародний новинний канал і вебсайт.",
      "ru" => "Cable News Network (CNN) — международный новостной канал и веб-сайт.",
      "pl" => "Cable News Network (CNN) to międzynarodowy kanał informacyjny i strona internetowa."
    },
    position: 102
  },
  {
    name: "The Guardian",
    slug: "guardian-am",
    url: "https://www.theguardian.com",
    logo_svg: '<svg width="110" height="50" viewBox="0 0 110 50" fill="none" xmlns="http://www.w3.org/2000/svg"><text x="5" y="25" font-family="Georgia" font-size="14" fill="white">The</text><text x="5" y="42" font-family="Georgia" font-weight="bold" font-size="18" fill="white">Guardian</text></svg>',
    description: {
      "en" => "The Guardian is a British daily newspaper founded in 1821.",
      "uk" => "The Guardian — британська щоденна газета, заснована в 1821 році.",
      "ru" => "The Guardian — британская ежедневная газета, основанная в 1821 году.",
      "pl" => "The Guardian to brytyjski dziennik założony w 1821 roku."
    },
    position: 103
  },
  {
    name: "Washington Post",
    slug: "washington-post-am",
    url: "https://www.washingtonpost.com",
    logo_svg: '<svg width="110" height="50" viewBox="0 0 110 50" fill="none" xmlns="http://www.w3.org/2000/svg"><text x="5" y="20" font-family="Times New Roman" font-size="11" fill="white">The</text><text x="5" y="35" font-family="Old English Text MT, Georgia" font-size="14" fill="white">Washington</text><text x="5" y="48" font-family="Old English Text MT, Georgia" font-size="14" fill="white">Post</text></svg>',
    description: {
      "en" => "The Washington Post is an American daily newspaper. It has won 69 Pulitzer Prizes.",
      "uk" => "The Washington Post — американська щоденна газета. Отримала 69 Пулітцерівських премій.",
      "ru" => "The Washington Post — американская ежедневная газета. Получила 69 Пулитцеровских премий.",
      "pl" => "The Washington Post to amerykański dziennik. Gazeta zdobyła 69 nagród Pulitzera."
    },
    position: 104
  },
  {
    name: "The Atlantic",
    slug: "atlantic-am",
    url: "https://www.theatlantic.com",
    logo_svg: '<svg width="110" height="50" viewBox="0 0 110 50" fill="none" xmlns="http://www.w3.org/2000/svg"><text x="10" y="20" font-family="Georgia" font-size="10" fill="white">THE</text><text x="10" y="38" font-family="Georgia" font-size="18" fill="white">ATLANTIC</text></svg>',
    description: {
      "en" => "The Atlantic is an American magazine founded in 1857.",
      "uk" => "The Atlantic — американський журнал, заснований у 1857 році.",
      "ru" => "The Atlantic — американский журнал, основанный в 1857 году.",
      "pl" => "The Atlantic to amerykański magazyn założony w 1857 roku."
    },
    position: 105
  }
]

ayder = User.find_by!(username: 'am')

partners_data.each do |pd|
  next if Partner.exists?(slug: pd[:slug])

  Partner.create!(
    name: pd[:name],
    slug: pd[:slug],
    url: pd[:url],
    logo_svg: pd[:logo_svg],
    description_i18n: pd[:description],
    position: pd[:position],
    active: true,
    user: ayder
  )
end

log("  Created #{partners_data.size} Blog AM partners")
