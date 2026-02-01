# frozen_string_literal: true

return if Post.exists?

log('Creating Sample Posts...')

# Get authors
author_pl = User.find_by(username: 'jan_kowalski')
author_uk = User.find_by(username: 'olena_shevchenko')
author_lt = User.find_by(username: 'jonas_kazlauskas')
admin = User.find_by(username: 'admin')

# Get categories - they belong to a user, so find by slug
cat_politics = Category.find_by(slug: 'politics')
cat_technology = Category.find_by(slug: 'technology')
cat_society = Category.find_by(slug: 'society')
cat_opinion = Category.find_by(slug: 'opinion')
cat_war = Category.find_by(slug: 'war-in-ukraine')
cat_digital_freedom = Category.find_by(slug: 'digital-freedom')

# Helper to create post with explicit slug
def create_post(author:, category:, titles:, contents:, slug:, excerpts: nil, status: 'published', tags: [])
  post = Post.new(
    author: author,
    category: category,
    status: status,
    slug: slug,
    comments_enabled: true,
    featured: false,
    published_at: status == 'published' ? Time.current : nil
  )
  post.title_i18n = titles
  post.content_i18n = contents
  post.lead_i18n = excerpts if excerpts
  post.save!

  # Add tags
  tags.each do |tag_slug|
    tag = Tag.find_by(slug: tag_slug)
    Tagging.create!(taggable: post, tag: tag) if tag
  end

  post
end

# Polish posts
if author_pl
  create_post(
    author: author_pl,
    category: cat_opinion,
    slug: 'wolnosc-slowa-w-dobie-algorytmow',
    titles: { 'pl' => 'Wolność słowa w dobie algorytmów' },
    contents: {
      'pl' => <<~CONTENT
        W dzisiejszych czasach wolność słowa nabrała nowego wymiaru. Nie chodzi już tylko o prawo do wyrażania swoich poglądów, ale o walkę z algorytmami, które decydują o tym, co widzimy i czytamy.

        Wielkie platformy technologiczne stały się strażnikami informacji. Decydują, które treści są "bezpieczne" i "właściwe", a które należy ukryć lub usunąć. Ta niewidzialna cenzura jest często bardziej skuteczna niż tradycyjne formy kontroli.

        ## Problem z moderacją treści

        Automatyczne systemy moderacji często nie rozumieją kontekstu. Artykuł dokumentujący zbrodnie wojenne może zostać usunięty za "przemoc", podczas gdy rzeczywista dezinformacja pozostaje nietknięta.

        ## Co możemy zrobić?

        1. Wspierać niezależne platformy
        2. Domagać się przejrzystości algorytmów
        3. Budować alternatywne kanały komunikacji
        4. Edukować społeczeństwo o mechanizmach cenzury

        Wolność słowa to nie przywilej, to fundament demokracji.
      CONTENT
    },
    excerpts: { 'pl' => 'W dzisiejszych czasach wolność słowa nabrała nowego wymiaru. Nie chodzi już tylko o prawo do wyrażania swoich poglądów, ale o walkę z algorytmami.' },
    tags: %w[freedom-of-speech censorship big-tech opinion]
  )

  create_post(
    author: author_pl,
    category: cat_politics,
    slug: 'europa-wobec-wyzwan-bezpieczenstwa',
    titles: { 'pl' => 'Europa wobec wyzwań bezpieczeństwa' },
    contents: {
      'pl' => <<~CONTENT
        Rosyjska agresja na Ukrainę zmieniła architekturę bezpieczeństwa w Europie. Państwa, które przez dekady inwestowały w soft power, muszą teraz pilnie odbudować swój potencjał obronny.

        ## Nowa rzeczywistość

        NATO zyskało na znaczeniu jak nigdy wcześniej. Finlandia i Szwecja dołączyły do sojuszu, a wydatki obronne rosną w całej Europie.

        ## Wyzwania dla Polski

        Polska, jako kraj frontowy, stoi przed szczególnymi wyzwaniami:
        - Modernizacja armii
        - Wzmocnienie obrony cywilnej
        - Odporność na dezinformację
        - Wsparcie dla uchodźców z Ukrainy

        Bezpieczeństwo kosztuje, ale brak bezpieczeństwa kosztuje znacznie więcej.
      CONTENT
    },
    excerpts: { 'pl' => 'Rosyjska agresja na Ukrainę zmieniła architekturę bezpieczeństwa w Europie.' },
    tags: %w[poland nato security diplomacy]
  )
end

# Ukrainian posts
if author_uk
  create_post(
    author: author_uk,
    category: cat_war,
    slug: 'holosy-z-frontu-istorii-yaki-potribno-pochuty',
    titles: { 'uk' => 'Голоси з фронту: історії, які потрібно почути' },
    contents: {
      'uk' => <<~CONTENT
        Війна — це не лише статистика та карти бойових дій. Це люди, їхні долі, страхи та надії. Сьогодні я хочу поділитися історіями, які почула від захисників України.

        ## Олексій, 28 років, Бахмут

        "Найважче — це невизначеність. Не знаєш, що буде завтра. Але ми тримаємось, бо знаємо, за що боремось."

        ## Марія, медик, Херсонщина

        "Кожне врятоване життя дає сили йти далі. Ми працюємо на межі можливостей, але не здаємось."

        ## Чому це важливо

        Ці історії потрібно чути всьому світу. Вони нагадують, що за кожною новиною стоять реальні люди з реальними переживаннями.

        Підтримка України — це не лише зброя та гроші. Це увага до голосів тих, хто бореться за свободу.
      CONTENT
    },
    excerpts: { 'uk' => 'Війна — це не лише статистика та карти бойових дій. Це люди, їхні долі, страхи та надії.' },
    tags: %w[ukraine war-crimes veterans truth]
  )

  create_post(
    author: author_uk,
    category: cat_society,
    slug: 'yak-pidtrymaty-veteraniv-praktychni-porady',
    titles: { 'uk' => 'Як підтримати ветеранів: практичні поради' },
    contents: {
      'uk' => <<~CONTENT
        Повернення з війни — це лише початок нового етапу. Багато ветеранів стикаються з ПТСР, проблемами адаптації та нерозумінням суспільства.

        ## Що можемо зробити ми?

        ### Слухати без осуду
        Не всі ветерани хочуть говорити про війну, але ті, хто хоче — потребують уважного слухача.

        ### Допомагати з побутовими справами
        Іноді найкраща допомога — це допомога з простими речами: документами, пошуком роботи, підтримкою родини.

        ### Розповсюджувати інформацію
        Інформуйте про програми підтримки, психологічну допомогу, можливості для ветеранів.

        ## Ресурси

        - Гарячі лінії психологічної допомоги
        - Центри реабілітації
        - Програми працевлаштування

        Разом ми можемо допомогти тим, хто захистив нас.
      CONTENT
    },
    excerpts: { 'uk' => 'Повернення з війни — це лише початок нового етапу. Багато ветеранів стикаються з ПТСР.' },
    tags: %w[veterans ptsd society human-rights]
  )
end

# Lithuanian posts
if author_lt
  create_post(
    author: author_lt,
    category: cat_politics,
    slug: 'baltijos-saliu-vienybe-krizes-metu',
    titles: { 'lt' => 'Baltijos šalių vienybė krizės metu' },
    contents: {
      'lt' => <<~CONTENT
        Rusijos agresija prieš Ukrainą parodė, kaip svarbu regioninis bendradarbiavimas. Lietuva, Latvija ir Estija demonstruoja vienybę, kuri gali būti pavyzdžiu visai Europai.

        ## Bendra gynyba

        Baltijos šalys jau seniai suprato grėsmę iš Rytų. Dabar šis supratimas tapo visuotiniu.

        ## Ekonominis atsparumas

        Atsisakymas rusiškų energijos išteklių, alternatyvių tiekimo kelių paieška, investicijos į atsinaujinančią energetiką — visa tai stiprina mūsų nepriklausomybę.

        ## Kultūrinis frontas

        Kova su dezinformacija, istorinės atminties puoselėjimas, švietimas apie propagandos metodus — tai ne mažiau svarbu nei karinė gynyba.

        Vienybė yra mūsų stiprybė.
      CONTENT
    },
    excerpts: { 'lt' => 'Rusijos agresija prieš Ukrainą parodė, kaip svarbu regioninis bendradarbiavimas.' },
    tags: %w[lithuania nato eu security]
  )
end

# English post from admin
if admin
  create_post(
    author: admin,
    category: cat_digital_freedom,
    slug: 'welcome-to-libremedia-our-mission-and-values',
    titles: { 'en' => 'Welcome to LibreMedia: Our Mission and Values' },
    contents: {
      'en' => <<~CONTENT
        Welcome to LibreMedia — a platform built on the principles of free speech, transparency, and respect for human dignity.

        ## Why LibreMedia?

        In an era of increasing digital censorship, we believe in creating spaces where people can express themselves freely, share information, and engage in meaningful dialogue.

        ## Our Principles

        ### Free Speech
        We defend the right to express unpopular opinions, document uncomfortable truths, and challenge power.

        ### Transparency
        Our moderation policies are clear and publicly documented. We don't hide behind vague "community guidelines."

        ### Privacy
        We respect your privacy. We don't sell your data or track your every move.

        ### Independence
        We're not beholden to advertisers or governments. Our users are our community, not our product.

        ## Join Us

        Whether you're a journalist, activist, veteran, or simply someone who values free expression — you're welcome here.

        Together, we can build a media ecosystem that serves the people, not the powerful.
      CONTENT
    },
    excerpts: { 'en' => 'Welcome to LibreMedia — a platform built on the principles of free speech, transparency, and respect for human dignity.' },
    tags: %w[freedom-of-speech digital-freedom journalism transparency]
  )
end

log("Created #{Post.count} posts")
