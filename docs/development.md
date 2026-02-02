# Środowisko deweloperskie

Przewodnik po konfiguracji lokalnego środowiska deweloperskiego dla LibreMedia.

---

## Wymagania

| Narzędzie | Wersja | Instalacja |
|-----------|--------|------------|
| Ruby | 3.4.6 | rbenv/rvm |
| PostgreSQL | 15+ | Homebrew/apt |
| Node.js | 24+ | nvm |
| Yarn | 1.22+ | npm |
| Redis | 7+ | Homebrew/apt |

### Opcjonalne

| Narzędzie | Opis |
|-----------|------|
| Elasticsearch 8.x | Wyszukiwanie pełnotekstowe |
| FFmpeg | Przetwarzanie wideo |
| ImageMagick | Przetwarzanie obrazów |

---

## Instalacja

### 1. Sklonuj repozytorium

```bash
git clone git@github.com:WebgateSystems/lmcore.git libremedia
cd libremedia
```

### 2. Zainstaluj Ruby

```bash
# rbenv
rbenv install 3.4.6
rbenv local 3.4.6

# LUB rvm
rvm install 3.4.6
rvm use 3.4.6
```

### 3. Zainstaluj Node.js

```bash
nvm install 24
nvm use 24
# lub użyj pliku .nvmrc
nvm use
```

### 4. Zainstaluj zależności

```bash
# Ruby gems
bundle install

# Node packages
yarn install
```

### 5. Skonfiguruj bazę danych

```bash
# Utwórz bazę i uruchom migracje
bin/rails db:prepare

# Załaduj dane przykładowe
bin/rails db:seed
```

### 6. Uruchom serwer

```bash
bin/dev
```

Aplikacja będzie dostępna pod `http://localhost:3000`

---

## Struktura katalogów

```
libremedia/
├── app/
│   ├── controllers/      # Kontrolery
│   │   ├── api/v1/       # API endpoints
│   │   └── concerns/     # Współdzielone moduły
│   ├── models/           # Modele ActiveRecord
│   │   └── concerns/     # Moduły modeli
│   ├── views/            # Widoki Slim
│   ├── javascript/       # Stimulus controllers
│   │   └── controllers/
│   ├── assets/
│   │   ├── stylesheets/  # SCSS
│   │   └── fonts/        # Font Awesome
│   ├── policies/         # Pundit policies
│   ├── services/         # Service objects
│   └── jobs/             # Background jobs
├── config/
│   ├── locales/          # Tłumaczenia i18n
│   └── settings.yml      # Konfiguracja aplikacji
├── db/
│   ├── migrate/          # Migracje
│   └── seeds/            # Dane seedowe
│       └── development/
├── docs/                 # Dokumentacja
├── spec/                 # Testy RSpec
│   ├── models/
│   ├── requests/
│   ├── system/
│   └── factories/
└── ...
```

---

## Komendy

### Rails

```bash
# Serwer deweloperski
bin/dev                    # Rails + JS/CSS watchers

# Konsola Rails
bin/rails c

# Migracje
bin/rails db:migrate
bin/rails db:rollback

# Seedy
bin/rails db:seed

# Routes
bin/rails routes | grep <pattern>

# Generatory
bin/rails g model User name:string
bin/rails g controller Posts index show
```

### RSpec (testy)

```bash
# Wszystkie testy
bundle exec rspec

# Konkretny plik
bundle exec rspec spec/models/user_spec.rb

# Konkretny test
bundle exec rspec spec/models/user_spec.rb:42

# Z tagiem
bundle exec rspec --tag focus

# Pokrycie kodu
COVERAGE=true bundle exec rspec
```

### Rubocop (linting)

```bash
# Sprawdzenie
bundle exec rubocop

# Auto-fix
bundle exec rubocop -a

# Konkretny plik
bundle exec rubocop app/models/user.rb
```

### Assets

```bash
# Build JS
npm run build

# Build CSS
yarn build:css

# Lub oba
npm run build && yarn build:css
```

---

## Aliasy (zalecane)

Dodaj do `~/.bashrc` lub `~/.zshrc`:

```bash
# LibreMedia shortcuts
alias rsc='rm -rf app/assets/builds/ && npm run build && yarn build:css && rails s'
alias rc='rails c'
alias rs='rails s'
alias rr='bundle exec rspec'
alias be='bundle exec'
```

---

## Konfiguracja

### config/settings.yml

Główny plik konfiguracji z wartościami domyślnymi.

### config/settings.local.yml

Lokalne nadpisania (nie commitowane):

```yaml
# config/settings.local.yml
stripe:
  publishable_key: pk_test_...
  secret_key: sk_test_...

elasticsearch:
  url: http://localhost:9200
```

### Zmienne środowiskowe

```bash
# .env (nie commitowany)
DATABASE_URL=postgresql://localhost/libremedia_development
REDIS_URL=redis://localhost:6379/0
```

---

## Baza danych

### Połączenie

```bash
# Rails console
bin/rails db

# Lub bezpośrednio
psql libremedia_development
```

### Reset

```bash
bin/rails db:drop db:create db:migrate db:seed
```

### Backup lokalny

```bash
pg_dump -Fc libremedia_development > backup.dump
pg_restore -d libremedia_development backup.dump
```

---

## Redis

### Uruchomienie

```bash
# macOS
brew services start redis

# Linux
sudo systemctl start redis
```

### Połączenie

```bash
redis-cli
> PING
PONG
```

---

## Sidekiq

### Uruchomienie

```bash
bundle exec sidekiq
```

### Web UI

Dostępny pod `/sidekiq` (wymaga zalogowania jako admin).

### Development mode

W development joby są wykonywane inline (synchronicznie). Aby testować z Sidekiq:

```ruby
# config/environments/development.rb
config.active_job.queue_adapter = :sidekiq
```

---

## Elasticsearch

### Uruchomienie

```bash
# macOS
brew services start elasticsearch

# Docker
docker run -d -p 9200:9200 -e "discovery.type=single-node" elasticsearch:8.11.0
```

### Reindeksowanie

```bash
bin/rails c
> Post.reindex
> Video.reindex
```

---

## Debugowanie

### Byebug

```ruby
# W kodzie
byebug
```

### Rails logger

```ruby
Rails.logger.debug "Debug info: #{variable.inspect}"
```

### Tail logs

```bash
tail -f log/development.log
```

---

## Git workflow

### Branching

- `main` — produkcja
- `develop` — staging
- `feature/*` — nowe funkcje
- `fix/*` — poprawki

### Commit messages

```
<type>: <description>

[optional body]

[optional footer]
```

Typy: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Pre-commit hooks

```bash
# .git/hooks/pre-commit
#!/bin/sh
bundle exec rubocop --force-exclusion
bundle exec rspec --fail-fast
```

---

## Troubleshooting

### Bundle install fails

```bash
# Aktualizuj bundler
gem install bundler
bundle update --bundler
```

### Yarn install fails

```bash
# Wyczyść cache
yarn cache clean
rm -rf node_modules
yarn install
```

### Database connection error

```bash
# Sprawdź czy PostgreSQL działa
pg_isready

# Restart
brew services restart postgresql
# lub
sudo systemctl restart postgresql
```

### Asset precompile error

```bash
# Wyczyść assets
rm -rf app/assets/builds/*
rm -rf tmp/cache

# Rebuild
npm run build && yarn build:css
```

---

## Powiązane dokumenty

- [testing.md](testing.md) — Testy i CI/CD
- [architecture.md](architecture.md) — Architektura systemu
