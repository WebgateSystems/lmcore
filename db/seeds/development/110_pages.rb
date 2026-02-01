# frozen_string_literal: true

return if Page.exists?

log('Creating Pages...')

admin = User.find_by(username: 'admin') || User.first!

log("  Using user '#{admin.username}' as page author")

# Helper to create page with translations
def create_page(author:, slug:, titles:, contents:, status: 'published', page_type: 'custom', show_in_menu: false, menu_position: 0)
  page = Page.new(
    author: author,
    slug: slug,
    status: status,
    page_type: page_type,
    show_in_menu: show_in_menu,
    menu_position: menu_position,
    published_at: status == 'published' ? Time.current : nil
  )
  page.title_i18n = titles
  page.content_i18n = contents
  page.save!
  page
end

# About page
create_page(
  author: admin,
  slug: 'about',
  page_type: 'about',
  titles: {
    'en' => 'About LibreMedia',
    'pl' => 'O LibreMedia',
    'uk' => 'Про LibreMedia',
    'lt' => 'Apie LibreMedia'
  },
  contents: {
    'en' => <<~CONTENT,
      # About LibreMedia

      LibreMedia is an independent multimedia publishing platform dedicated to free speech and quality journalism.

      ## Our Mission

      We believe that free expression is fundamental to democracy. In an era of increasing censorship and algorithmic manipulation, we provide a space where voices can be heard without fear of arbitrary silencing.

      ## What We Offer

      - **Personal Blogs & Vlogs**: Create your own space for content
      - **Import/Export Freedom**: Your data belongs to you
      - **Multiple Languages**: Full support for Polish, Ukrainian, Lithuanian, and English
      - **Community Features**: Forums, chat, and live streaming
      - **Reputation System**: Evidence-based accountability for public figures

      ## Who We Serve

      - Journalists and media professionals
      - Public opinion leaders
      - Veterans documenting their experiences
      - Anyone who values free expression

      ## Contact

      For inquiries: contact@libremedia.org
    CONTENT
    'pl' => <<~CONTENT,
      # O LibreMedia

      LibreMedia to niezależna platforma publikacyjna multimedialna poświęcona wolności słowa i jakościowemu dziennikarstwu.

      ## Nasza Misja

      Wierzymy, że wolność słowa jest fundamentem demokracji. W erze rosnącej cenzury i algorytmicznej manipulacji, zapewniamy przestrzeń, gdzie głosy mogą być słyszane bez obawy o arbitralne uciszanie.

      ## Co Oferujemy

      - **Blogi i Vlogi**: Stwórz własną przestrzeń na treści
      - **Wolność Importu/Eksportu**: Twoje dane należą do Ciebie
      - **Wiele Języków**: Pełne wsparcie dla polskiego, ukraińskiego, litewskiego i angielskiego
      - **Funkcje Społeczności**: Fora, czat i transmisje na żywo
      - **System Reputacji**: Odpowiedzialność osób publicznych oparta na dowodach

      ## Kontakt

      Zapytania: contact@libremedia.org
    CONTENT
    'uk' => <<~CONTENT,
      # Про LibreMedia

      LibreMedia — це незалежна мультимедійна видавнича платформа, присвячена свободі слова та якісній журналістиці.

      ## Наша Місія

      Ми віримо, що свобода вираження є фундаментом демократії.

      ## Контакт

      Запити: contact@libremedia.org
    CONTENT
    'lt' => <<~CONTENT
      # Apie LibreMedia

      LibreMedia yra nepriklausoma multimedijos leidybos platforma, skirta žodžio laisvei ir kokybiškam žurnalizmui.

      ## Mūsų Misija

      Tikime, kad saviraiškos laisvė yra demokratijos pagrindas.

      ## Kontaktai

      Užklausos: contact@libremedia.org
    CONTENT
  },
  show_in_menu: true,
  menu_position: 0
)

# Terms of Service
create_page(
  author: admin,
  slug: 'terms',
  page_type: 'terms',
  titles: {
    'en' => 'Terms of Service',
    'pl' => 'Regulamin',
    'uk' => 'Умови використання',
    'lt' => 'Paslaugų teikimo sąlygos'
  },
  contents: {
    'en' => <<~CONTENT,
      # Terms of Service

      Last updated: #{Date.today.strftime('%B %d, %Y')}

      ## 1. Acceptance of Terms

      By accessing and using LibreMedia, you accept and agree to be bound by these Terms of Service.

      ## 2. User Accounts

      - You must provide accurate information when creating an account
      - You are responsible for maintaining the security of your account
      - You must be at least 16 years old to use this service

      ## 3. Content Guidelines

      While we support free speech, the following content is prohibited:
      - Illegal content under applicable law
      - Child exploitation material
      - Direct threats of violence against individuals
      - Spam and automated abuse

      ## 4. Intellectual Property

      - You retain ownership of content you create
      - By posting, you grant LibreMedia a license to display your content
      - You must not infringe on others' intellectual property rights

      ## 5. Limitation of Liability

      LibreMedia is provided "as is" without warranties of any kind.

      ## 6. Changes to Terms

      We may modify these terms at any time. Continued use constitutes acceptance of changes.

      ## 7. Contact

      Questions: legal@libremedia.org
    CONTENT
    'pl' => <<~CONTENT,
      # Regulamin

      Ostatnia aktualizacja: #{Date.today.strftime('%d.%m.%Y')}

      ## 1. Akceptacja Warunków

      Korzystając z LibreMedia, akceptujesz niniejszy Regulamin.

      ## 2. Konta Użytkowników

      - Musisz podać prawdziwe dane przy rejestracji
      - Odpowiadasz za bezpieczeństwo swojego konta
      - Musisz mieć co najmniej 16 lat

      ## 3. Zasady Dotyczące Treści

      Zabronione są:
      - Treści nielegalne
      - Materiały przedstawiające wykorzystywanie dzieci
      - Bezpośrednie groźby przemocy
      - Spam

      ## Kontakt

      Pytania: legal@libremedia.org
    CONTENT
    'uk' => "# Умови використання\n\nКонтакт: legal@libremedia.org",
    'lt' => "# Paslaugų teikimo sąlygos\n\nKontaktai: legal@libremedia.org"
  },
  show_in_menu: true,
  menu_position: 1
)

# Privacy Policy
create_page(
  author: admin,
  slug: 'privacy',
  page_type: 'privacy',
  titles: {
    'en' => 'Privacy Policy',
    'pl' => 'Polityka Prywatności',
    'uk' => 'Політика конфіденційності',
    'lt' => 'Privatumo politika'
  },
  contents: {
    'en' => <<~CONTENT,
      # Privacy Policy

      Last updated: #{Date.today.strftime('%B %d, %Y')}

      ## What We Collect

      - Account information (email, username)
      - Content you create
      - Technical data (IP addresses, browser info) for security

      ## What We Don't Do

      - We don't sell your data
      - We don't track you across the web
      - We don't share your data with advertisers

      ## Your Rights

      - Access your data
      - Export your data
      - Delete your account

      ## Security

      We use industry-standard security measures to protect your data.

      ## Contact

      Privacy inquiries: privacy@libremedia.org
    CONTENT
    'pl' => <<~CONTENT,
      # Polityka Prywatności

      Ostatnia aktualizacja: #{Date.today.strftime('%d.%m.%Y')}

      ## Co Zbieramy

      - Dane konta (email, nazwa użytkownika)
      - Treści, które tworzysz
      - Dane techniczne (adresy IP) dla bezpieczeństwa

      ## Czego Nie Robimy

      - Nie sprzedajemy Twoich danych
      - Nie śledzimy Cię w sieci
      - Nie dzielimy się danymi z reklamodawcami

      ## Kontakt

      privacy@libremedia.org
    CONTENT
    'uk' => "# Політика конфіденційності\n\nКонтакт: privacy@libremedia.org",
    'lt' => "# Privatumo politika\n\nKontaktai: privacy@libremedia.org"
  },
  show_in_menu: true,
  menu_position: 2
)

# Contact page
create_page(
  author: admin,
  slug: 'contact',
  page_type: 'contact',
  titles: {
    'en' => 'Contact Us',
    'pl' => 'Kontakt',
    'uk' => 'Контакти',
    'lt' => 'Kontaktai'
  },
  contents: {
    'en' => <<~CONTENT,
      # Contact Us

      ## General Inquiries
      Email: contact@libremedia.org

      ## Support
      Email: support@libremedia.org

      ## Press & Media
      Email: press@libremedia.org

      ## Legal
      Email: legal@libremedia.org

      ## Social Media
      - Twitter: @libremedia
      - Telegram: t.me/libremedia
    CONTENT
    'pl' => <<~CONTENT,
      # Kontakt

      ## Zapytania Ogólne
      Email: contact@libremedia.org

      ## Wsparcie
      Email: support@libremedia.org

      ## Prasa i Media
      Email: press@libremedia.org

      ## Sprawy Prawne
      Email: legal@libremedia.org
    CONTENT
    'uk' => "# Контакти\n\nEmail: contact@libremedia.org",
    'lt' => "# Kontaktai\n\nEl. paštas: contact@libremedia.org"
  },
  show_in_menu: true,
  menu_position: 3
)

log("Created #{Page.count} pages")
