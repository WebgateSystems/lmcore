# frozen_string_literal: true

ayder = User.find_by!(email: 'ayder@gmail.com')
return if ayder.pages.exists?

log('  [Blog AM] Creating pages...')

# About page
about = Page.new(
  author: ayder,
  slug: 'about',
  page_type: 'about',
  status: 'published',
  published_at: Time.current,
  published_by: ayder,
  show_in_menu: true,
  menu_position: 1
)
about.title_i18n = {
  'en' => 'About Me',
  'uk' => 'Про мене',
  'ru' => 'Обо мне',
  'pl' => 'O mnie'
}
about.content_i18n = {
  'en' => '<p><strong>Ayder Muzhdabaev</strong> — Ukrainian journalist, media manager and publicist of Crimean Tatar descent. Born 8 March 1972 in Tambov (USSR). Since 2016 — citizen of Ukraine.</p><p>He worked for many years in Russia (notably as deputy editor-in-chief of the newspaper <em>Moskovskij Komsomolets</em>) until 2015, when — after the Russian invasion of Ukraine and annexation of Crimea — he relocated to Ukraine.</p><p>Since June 2015 he has served as Deputy General Director of the Crimean-Tatar television channel <em>ATR</em>. Since October 2017 — host of the weekly program <em>"Prime: Muzhdabaev"</em> on ATR. He is also co-author of the report <em>Putin. War</em> about Russian aggression and the annexation of Crimea.</p><p>Ayder Muzhdabaev actively advocates for the rights of the Crimean Tatar people, freedom of speech, and preservation of Ukrainian sovereignty. As a result of his public position, since 2020 he is persecuted by Russian authorities — declared internationally wanted, sentenced in absentia to six years of imprisonment (2023), and included in Russia\'s official register of "foreign agents".</p>',
  'uk' => '<p><strong>Айдер Муждабаєв</strong> — український журналіст, медіаменеджер і публіцист кримськотатарського походження. Народився 8 березня 1972 року в Тамбові (СРСР). З 2016 року — громадянин України.</p><p>Протягом багатьох років працював у Росії — зокрема як заступник головного редактора газети <em>«Московский комсомолец»</em>, до 2015 року. Після початку повномасштабної війни Росії проти України та анексії Криму переїхав до України.</p><p>З червня 2015 року — заступник генерального директора кримськотатарського телеканалу <em>ATR</em>. З жовтня 2017 — ведучий щотижневої програми <em>«Prime: Муждабаєв»</em> на ATR. Також є спів­автором звіту <em>Putin. War</em> про російську агресію та анексію Криму.</p><p>Активно відстоює права кримськотатарського народу, свободу слова та суверенітет України. Через свою публічну позицію з 2020 року зазнає переслідувань з боку російської влади — оголошений у міжнародний розшук, 2023 року заочно засуджений до шести років позбавлення волі, внесений до списку «іноземних агентів» РФ.</p>',
  'ru' => '<p><strong>Айдер Муждабаев</strong> — украинский журналист, медиаменеджер и публицист крымскотатарского происхождения. Родился 8 марта 1972 года в Тамбове (СССР). С 2016 года — гражданин Украины.</p><p>Много лет работал в России — в том числе был заместителем главного редактора газеты <em>«Московский комсомолец»</em>, до 2015 года. После начала полномасштабной войны России против Украины и аннексии Крыма переехал в Украину.</p><p>С июня 2015 года — заместитель генерального директора крымскотатарского телеканала <em>ATR</em>. С октября 2017 — ведущий еженедельной программы <em>«Prime: Муждабаев»</em> на ATR. Также является соавтором доклада <em>Putin. War</em> о российской агрессии и аннексии Крыма.</p><p>Активно защищает права крымскотатарского народа, свободу слова и суверенитет Украины. В связи с публичной позицией с 2020 года подвергается преследованиям со стороны российских властей — объявлен в международный розыск, в 2023 году заочно приговорён к шести годам лишения свободы, включён в список «иностранных агентов» РФ.</p>',
  'pl' => '<p><strong>Ayder Muzhdabaev</strong> — ukraiński dziennikarz, menedżer mediów i publicysta pochodzenia krymskotatarskiego. Urodził się 8 marca 1972 roku w Tambowie (ZSRR). Od 2016 roku posiada obywatelstwo Ukrainy.</p><p>Przez wiele lat pracował w Rosji — w tym jako zastępca redaktora naczelnego gazety <em>«Moskovskij Komsomolets»</em> do 2015 roku. Po rozpoczęciu pełnoskalowej agresji Rosji na Ukrainę i aneksji Krymu przeprowadził się na Ukrainę.</p><p>Od czerwca 2015 roku jest zastępcą dyrektora generalnego krymskotatarskiego kanału telewizyjnego <em>ATR</em>. Od października 2017 roku prowadzi cotygodniowy program <em>«Prime: Muzhdabaev»</em> na ATR. Jest także współautorem raportu <em>Putin. War</em> o rosyjskiej agresji i aneksji Krymu.</p><p>Aktywnie broni praw narodu krymskotatarskiego, wolności słowa i suwerenności Ukrainy. Z powodu swojej publicznej postawy od 2020 roku jest prześladowany przez władze Rosji — został wpisany na międzynarodowy list poszukiwanych, w 2023 roku skazany zaocznie na sześć lat więzienia, został wpisany na listę „zagranicznych agentów" Federacji Rosyjskiej.</p>'
}
about.menu_title_i18n = {
  'en' => 'About',
  'uk' => 'Про мене',
  'ru' => 'Обо мне',
  'pl' => 'O mnie'
}
about.save!

# Terms of Use
terms = Page.new(
  author: ayder,
  slug: 'terms-of-use',
  page_type: 'terms',
  status: 'published',
  published_at: Time.current,
  published_by: ayder,
  show_in_menu: false,
  menu_position: 10
)
terms.title_i18n = {
  'en' => 'Terms of Use',
  'uk' => 'Умови використання',
  'ru' => 'Условия использования',
  'pl' => 'Regulamin'
}
terms.content_i18n = {
  'en' => '<h2>Terms of Use</h2><p>By using this website, you agree to these terms and conditions...</p>',
  'uk' => '<h2>Умови використання</h2><p>Використовуючи цей веб-сайт, ви погоджуєтеся з цими умовами...</p>',
  'ru' => '<h2>Условия использования</h2><p>Используя этот веб-сайт, вы соглашаетесь с настоящими условиями...</p>',
  'pl' => '<h2>Regulamin</h2><p>Korzystając z tej strony internetowej, akceptujesz niniejszy regulamin...</p>'
}
terms.save!

log("  [Blog AM] Created #{ayder.pages.count} pages")
