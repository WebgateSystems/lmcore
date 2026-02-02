# LibreMedia

[![Ruby](https://img.shields.io/badge/Ruby-3.4.6-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.2-D30001?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![License: SACL](https://img.shields.io/badge/License-SACL--1.0-orange.svg)](LICENSE.md)

---

Języki: **Polski (domyślny)** · [English](README.en.md) · [Українська](README.uk.md)

---

## Czym jest LibreMedia?

**LibreMedia** to niezależna platforma multimedialna SaaS dla twórców, dziennikarzy i liderów opinii, którzy cenią **wolność słowa** i **niezależność mediów**.

Platforma umożliwia:
- 📹 Publikowanie treści multimedialnych (wideo, zdjęcia, artykuły)
- 💰 Monetyzację poprzez subskrypcje i darowizny
- 👥 Budowanie społeczności wokół wartości demokratycznych
- 🌍 Globalny zasięg z wielojęzycznym interfejsem (PL, EN, UK, LT, DE, FR, ES)

> **Wolne media to niezależne media.**  
> Prawdziwa niezależność wymaga niezależności finansowej — gdy świadomi użytkownicy wspierają twórców bezpośrednio.

---

## Dlaczego kod źródłowy jest publiczny?

LibreMedia to **komercyjna platforma SaaS** z **publicznie dostępnym kodem źródłowym**.

Kod jest publiczny, aby zapewnić:

- 🔍 **Transparentność i bezpieczeństwo** — każdy może audytować kod i zweryfikować brak backdoorów czy spyware
- 🧠 **Otwartość techniczna** — architektura i decyzje implementacyjne są widoczne
- 🤝 **Wkład społeczności** — pull requesty z poprawkami i ulepszeniami są mile widziane

### Czy LibreMedia jest open source?

**Nie.**

LibreMedia jest **source-available**, nie open source w rozumieniu OSI. To rozróżnienie jest celowe i jasno komunikowane. Szczegóły w [LICENSE.md](LICENSE.md).

---

## Dokumentacja

| Dokument | Opis |
|----------|------|
| [docs/README.md](docs/README.md) | Główna dokumentacja techniczna |
| [docs/architecture.md](docs/architecture.md) | Architektura systemu |
| [docs/api.md](docs/api.md) | Dokumentacja API |
| [docs/database.md](docs/database.md) | Struktura bazy danych i ERD |
| [docs/deployment.md](docs/deployment.md) | Instrukcje wdrożenia |
| [LICENSE.md](LICENSE.md) | Licencja SACL-1.0 |

---

## Wymagania (lokalnie)

- **Ruby**: `3.4.6` (patrz `.ruby-version`)
- **PostgreSQL**: 15+
- **Node.js**: 24+ (patrz `.node-version` / `.nvmrc`)
- **Yarn**: 1.22+
- **Redis**: 7+ (dla Sidekiq)
- **Elasticsearch**: 8.x (opcjonalnie, dla wyszukiwania)

## Szybki start

### 1. Zainstaluj zależności

```bash
# Ruby
bundle install

# JavaScript
yarn install
```

### 2. Skonfiguruj bazę danych

```bash
bin/rails db:prepare
```

### 3. Załaduj dane przykładowe (development)

```bash
bin/rails db:seed
```

### 4. Uruchom serwer

```bash
bin/dev
```

Aplikacja będzie dostępna pod `http://localhost:3000`

---

## Konfiguracja

Domyślne ustawienia znajdują się w `config/settings.yml`. Najważniejsze zmienne środowiskowe:

| Zmienna | Opis |
|---------|------|
| `DATABASE_URL` | URL połączenia z PostgreSQL |
| `REDIS_URL` | URL połączenia z Redis |
| `DEVISE_JWT_SECRET_KEY` | Sekret JWT dla API |
| `ELASTICSEARCH_URL` | URL Elasticsearch (opcjonalnie) |
| `STRIPE_*` | Klucze Stripe do płatności |
| `SMTP_*` | Konfiguracja e-mail |

---

## Testy

### Testy jednostkowe (RSpec)

```bash
bundle exec rspec
```

### Pokrycie kodu

Po uruchomieniu testów raport pokrycia jest generowany w `coverage/index.html`.

---

## Usługi / komponenty

- **Sidekiq** — przetwarzanie zadań w tle
- **Elasticsearch** — wyszukiwanie pełnotekstowe
- **Stripe** — płatności i subskrypcje
- **Action Cable** — WebSocket dla powiadomień w czasie rzeczywistym

---

## Deployment

Wdrożenia są realizowane przez Capistrano:

```bash
cap staging deploy
cap production deploy
```

Szczegóły w [docs/deployment.md](docs/deployment.md).

---

## Wkład (Contributing)

Pull requesty są mile widziane!

Przesyłając wkład, zgadzasz się, że może on zostać włączony do komercyjnego produktu LibreMedia bez dodatkowego wynagrodzenia.

Szczegóły w [LICENSE.md](LICENSE.md).

---

## Własność

LibreMedia jest rozwijana i obsługiwana przez **Webgate Systems LTD (Wielka Brytania)**.

| | |
|---|---|
| **Strona** | [webgate.pro](https://webgate.pro) |
| **E-mail** | [legal@webgate.pro](mailto:legal@webgate.pro) |
| **GitHub** | [github.com/WebgateSystems/lmcore](https://github.com/WebgateSystems/lmcore) |

---

<p align="center">
  <strong>© 2026 Webgate Systems LTD</strong><br>
  <em>LibreMedia — Wolność Słowa, Wolne Media</em>
</p>
