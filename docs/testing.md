# Testowanie LibreMedia

## Przegląd

LibreMedia używa RSpec jako głównego frameworka testowego z celem pokrycia kodu ≥90%.

---

## Stos testowy

| Gem | Zastosowanie |
|-----|--------------|
| rspec-rails | Framework testowy |
| factory_bot_rails | Fabryki danych testowych |
| faker | Generowanie losowych danych |
| shoulda-matchers | Matchery dla walidacji/asocjacji |
| capybara | Testy systemowe (UI) |
| selenium-webdriver | Driver dla testów JS |
| simplecov | Pokrycie kodu |
| database_cleaner | Czyszczenie bazy między testami |
| webmock | Mockowanie HTTP |
| vcr | Nagrywanie odpowiedzi HTTP |

---

## Struktura katalogów

```
spec/
├── controllers/      # Testy kontrolerów (rzadko używane)
├── factories/        # FactoryBot factories
├── models/           # Testy modeli
├── policies/         # Testy Pundit policies
├── requests/         # Testy integracyjne (request specs)
├── routing/          # Testy routingu
├── services/         # Testy service objects
├── support/          # Helpery i konfiguracja
│   ├── capybara.rb
│   ├── database_cleaner.rb
│   ├── factory_bot.rb
│   └── shared_examples.rb
├── system/           # Testy end-to-end (Capybara)
├── views/            # Testy widoków
├── rails_helper.rb   # Konfiguracja Rails
└── spec_helper.rb    # Konfiguracja RSpec
```

---

## Uruchamianie testów

### Wszystkie testy

```bash
bundle exec rspec
```

### Konkretny plik

```bash
bundle exec rspec spec/models/user_spec.rb
```

### Konkretna linia

```bash
bundle exec rspec spec/models/user_spec.rb:42
```

### Konkretny tag

```bash
# Tylko testy z tagiem :focus
bundle exec rspec --tag focus

# Pomijaj testy z tagiem :slow
bundle exec rspec --tag ~slow
```

### Format wyjścia

```bash
# Dots (domyślny)
bundle exec rspec

# Documentation
bundle exec rspec --format documentation

# HTML report
bundle exec rspec --format html --out rspec_results.html
```

---

## Typy testów

### Model specs

Testują logikę modeli, walidacje, scopes, metody.

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:username) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'scopes' do
    describe '.verified' do
      it 'returns only verified users' do
        verified = create(:user, :verified)
        unverified = create(:user)
        
        expect(User.verified).to include(verified)
        expect(User.verified).not_to include(unverified)
      end
    end
  end

  describe '#full_name' do
    it 'returns first and last name combined' do
      user = build(:user, first_name: 'Jan', last_name: 'Kowalski')
      expect(user.full_name).to eq('Jan Kowalski')
    end
  end
end
```

### Request specs

Testują pełny cykl request-response (zalecane zamiast controller specs).

```ruby
# spec/requests/posts_spec.rb
RSpec.describe 'Posts', type: :request do
  describe 'GET /posts' do
    let!(:published_post) { create(:post, :published) }
    let!(:draft_post) { create(:post, :draft) }

    it 'returns only published posts' do
      get posts_path
      
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(published_post.title)
      expect(response.body).not_to include(draft_post.title)
    end
  end

  describe 'POST /posts' do
    let(:user) { create(:user) }
    let(:valid_params) do
      { post: { title: 'New Post', content: 'Content here' } }
    end

    context 'when authenticated' do
      before { sign_in user }

      it 'creates a new post' do
        expect {
          post posts_path, params: valid_params
        }.to change(Post, :count).by(1)
        
        expect(response).to redirect_to(post_path(Post.last))
      end
    end

    context 'when not authenticated' do
      it 'redirects to login' do
        post posts_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
```

### System specs

Testy end-to-end symulujące interakcje użytkownika w przeglądarce.

```ruby
# spec/system/login_spec.rb
RSpec.describe 'Login', type: :system do
  let(:user) { create(:user, password: 'password123') }

  before do
    driven_by(:rack_test)
  end

  it 'allows user to login with valid credentials' do
    visit login_path
    
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password123'
    click_button 'Zaloguj się'
    
    expect(page).to have_content('Zalogowano pomyślnie')
    expect(page).to have_link('Wyloguj')
  end

  it 'shows error with invalid credentials' do
    visit login_path
    
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'wrong_password'
    click_button 'Zaloguj się'
    
    expect(page).to have_content('Nieprawidłowy email lub hasło')
  end
end
```

### Policy specs

Testują autoryzację Pundit.

```ruby
# spec/policies/post_policy_spec.rb
RSpec.describe PostPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:post) { create(:post, author: user) }

  subject { described_class }

  permissions :update?, :destroy? do
    it 'denies access to other users' do
      other_user = create(:user)
      expect(subject).not_to permit(other_user, post)
    end

    it 'grants access to author' do
      expect(subject).to permit(user, post)
    end

    it 'grants access to admin' do
      expect(subject).to permit(admin, post)
    end
  end

  describe 'Scope' do
    let!(:published) { create(:post, :published) }
    let!(:draft) { create(:post, :draft, author: user) }
    let!(:other_draft) { create(:post, :draft) }

    it 'shows published posts and own drafts' do
      scope = Pundit.policy_scope!(user, Post)
      
      expect(scope).to include(published)
      expect(scope).to include(draft)
      expect(scope).not_to include(other_draft)
    end
  end
end
```

---

## Factories

### Definiowanie factory

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    username { Faker::Internet.unique.username }
    password { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    status { 'active' }
    confirmed_at { Time.current }
    
    # System ról używa RoleAssignment (patrz: docs/features/users.md)
    trait :admin do
      after(:create) do |user|
        admin_role = Role.find_by(slug: "admin") || Role.create!(
          slug: "admin", name: "Admin", permissions: %w[manage_users manage_content],
          priority: 90, system_role: true
        )
        create(:role_assignment, user: user, role: admin_role)
      end
    end
    
    trait :super_admin do
      after(:create) do |user|
        super_admin_role = Role.find_by(slug: "super-admin") || Role.create!(
          slug: "super-admin", name: "Super Admin", permissions: ["*"],
          priority: 100, system_role: true
        )
        create(:role_assignment, user: user, role: super_admin_role)
      end
    end
    
    trait :author do
      after(:create) do |user|
        author_role = Role.find_by(slug: "author") || Role.create!(
          slug: "author", name: "Author", permissions: %w[create_content edit_own_content],
          priority: 30, system_role: true
        )
        create(:role_assignment, user: user, role: author_role)
      end
    end
  end
end
```

### Używanie factories

```ruby
# Tworzenie (zapisuje do bazy)
user = create(:user)
verified_user = create(:user, :verified)
admin = create(:user, :admin, first_name: 'Admin')

# Budowanie (nie zapisuje)
user = build(:user)
user = build_stubbed(:user)

# Lista
users = create_list(:user, 5)
```

---

## Shared examples

```ruby
# spec/support/shared_examples.rb
RSpec.shared_examples 'sluggable' do
  describe 'slug generation' do
    it 'generates slug from title' do
      record = create(described_class.model_name.singular, title: 'Test Title')
      expect(record.slug).to eq('test-title')
    end
    
    it 'ensures slug uniqueness' do
      create(described_class.model_name.singular, title: 'Test')
      record = create(described_class.model_name.singular, title: 'Test')
      expect(record.slug).to match(/test-\w+/)
    end
  end
end

# Użycie
RSpec.describe Post, type: :model do
  it_behaves_like 'sluggable'
end
```

---

## Pokrycie kodu

### SimpleCov

```ruby
# spec/rails_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Policies', 'app/policies'
  
  minimum_coverage 90
  minimum_coverage_by_file 80
end
```

### Raport

Po uruchomieniu testów raport dostępny w `coverage/index.html`.

---

## CI/CD

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        ports:
          - 6379:6379
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: 'yarn'
      
      - name: Install dependencies
        run: |
          bundle install
          yarn install
      
      - name: Setup database
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost/test
        run: |
          bin/rails db:prepare
      
      - name: Run tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost/test
          RAILS_ENV: test
        run: bundle exec rspec
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## Best practices

1. **Testuj zachowanie, nie implementację**
2. **Jeden assert na test** (gdy możliwe)
3. **Używaj factories zamiast fixtures**
4. **Mockuj zewnętrzne serwisy**
5. **Utrzymuj testy szybkie** (taguj wolne jako `:slow`)
6. **Unikaj testów zależnych od kolejności**
7. **Czyść bazę między testami** (DatabaseCleaner)

---

## Powiązane dokumenty

- [development.md](development.md) — Środowisko deweloperskie
- [architecture.md](architecture.md) — Architektura systemu
