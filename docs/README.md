# Dokumentacja LibreMedia

Ta dokumentacja zawiera szczegółowe informacje techniczne o platformie LibreMedia.

## Spis treści

### Architektura i projektowanie

| Dokument | Opis |
|----------|------|
| [architecture.md](architecture.md) | Architektura systemu, komponenty, warstwy |
| [database.md](database.md) | Struktura bazy danych, ERD, modele |
| [api.md](api.md) | Dokumentacja REST API |

### Funkcjonalności

| Dokument | Opis |
|----------|------|
| [features/content.md](features/content.md) | System treści (posty, wideo, zdjęcia) |
| [features/monetization.md](features/monetization.md) | Subskrypcje, darowizny, płatności |
| [features/users.md](features/users.md) | Użytkownicy, role, uprawnienia |
| [features/social.md](features/social.md) | Obserwacje, komentarze, reakcje |

### Infrastruktura

| Dokument | Opis |
|----------|------|
| [deployment.md](deployment.md) | Instrukcje wdrożenia (Capistrano) |
| [infrastructure.md](infrastructure.md) | Serwery, bazy danych, CDN |
| [monitoring.md](monitoring.md) | Monitoring, logi, alerty |

### Dla deweloperów

| Dokument | Opis |
|----------|------|
| [development.md](development.md) | Środowisko lokalne, konwencje |
| [testing.md](testing.md) | Testy, pokrycie, CI/CD |
| [i18n.md](i18n.md) | Internacjonalizacja, tłumaczenia |

---

## Quick Links

- **README**: [../README.md](../README.md) (PL) · [../README.en.md](../README.en.md) (EN) · [../README.uk.md](../README.uk.md) (UK)
- **Licencja**: [../LICENSE.md](../LICENSE.md)
- **API Swagger**: `/api-docs/index.html` (po uruchomieniu serwera)

---

## Kluczowe koncepty

### Platforma multimedialna

LibreMedia to platforma dla twórców treści, umożliwiająca:

1. **Publikowanie** — posty, wideo, zdjęcia, strony statyczne
2. **Monetyzację** — subskrypcje premium, jednorazowe darowizny
3. **Społeczność** — obserwacje, komentarze, reakcje, powiadomienia
4. **Wielojęzyczność** — pełne wsparcie i18n (PL, EN, UK, LT, DE, FR, ES)

### Stos technologiczny

```
┌─────────────────────────────────────────────────┐
│                   Frontend                       │
│  Hotwire (Turbo + Stimulus) · SCSS · Font Awesome│
├─────────────────────────────────────────────────┤
│                   Backend                        │
│  Ruby on Rails 8.1.2 · Ruby 3.4.6               │
├─────────────────────────────────────────────────┤
│                   Data Layer                     │
│  PostgreSQL 15+ · Redis 7+ · Elasticsearch 8.x  │
├─────────────────────────────────────────────────┤
│                   Services                       │
│  Sidekiq · Stripe · Action Cable                │
└─────────────────────────────────────────────────┘
```

### Role użytkowników

| Rola | Opis | Uprawnienia |
|------|------|-------------|
| `guest` | Niezalogowany użytkownik | Przeglądanie publicznych treści |
| `user` | Zarejestrowany użytkownik | Komentarze, obserwacje, reakcje |
| `creator` | Twórca treści | Publikowanie, monetyzacja |
| `moderator` | Moderator | Moderacja treści i komentarzy |
| `admin` | Administrator | Pełny dostęp do systemu |

### Typy treści

| Typ | Model | Opis |
|-----|-------|------|
| Post | `Post` | Artykuły tekstowe z formatowaniem |
| Video | `Video` | Materiały wideo (YouTube, upload) |
| Photo | `Photo` | Galerie zdjęć |
| Page | `Page` | Strony statyczne |

### Monetyzacja

| Mechanizm | Opis |
|-----------|------|
| Subskrypcje | Miesięczne/roczne plany premium |
| Darowizny | Jednorazowe wpłaty na twórcę |
| Poziomy dostępu | Treści dostępne tylko dla subskrybentów |

---

## Diagram architektury

```
                                    ┌──────────────┐
                                    │   CDN/Edge   │
                                    │  (CloudFlare)│
                                    └──────┬───────┘
                                           │
                    ┌──────────────────────┴──────────────────────┐
                    │                                              │
           ┌────────▼────────┐                          ┌─────────▼─────────┐
           │   Web Server    │                          │   API Gateway     │
           │   (Nginx)       │                          │   (REST/JSON)     │
           └────────┬────────┘                          └─────────┬─────────┘
                    │                                              │
                    └──────────────────────┬───────────────────────┘
                                           │
                                  ┌────────▼────────┐
                                  │  Rails App      │
                                  │  (Puma)         │
                                  └────────┬────────┘
                                           │
           ┌───────────────┬───────────────┼───────────────┬───────────────┐
           │               │               │               │               │
   ┌───────▼───────┐ ┌─────▼─────┐ ┌───────▼───────┐ ┌─────▼─────┐ ┌───────▼───────┐
   │  PostgreSQL   │ │   Redis   │ │ Elasticsearch │ │  Sidekiq  │ │    Stripe     │
   │  (Primary DB) │ │  (Cache)  │ │   (Search)    │ │  (Jobs)   │ │  (Payments)   │
   └───────────────┘ └───────────┘ └───────────────┘ └───────────┘ └───────────────┘
```

---

## Konwencje

### Nazewnictwo

- Modele: `CamelCase` (np. `PricePlan`, `MediaAttachment`)
- Tabele: `snake_case`, liczba mnoga (np. `price_plans`, `media_attachments`)
- Kontrolery: `PluralController` (np. `PostsController`)
- Widoki: `snake_case` (np. `posts/show.html.slim`)

### Struktura katalogów

```
app/
├── controllers/          # Kontrolery (Web + API)
│   ├── api/v1/          # API v1
│   └── concerns/        # Współdzielone moduły
├── models/              # Modele ActiveRecord
│   └── concerns/        # Współdzielone moduły (Sluggable, Translatable)
├── views/               # Widoki Slim
├── javascript/          # Stimulus controllers
│   └── controllers/     
├── assets/              
│   ├── stylesheets/     # SCSS
│   └── fonts/           # Font Awesome
├── policies/            # Pundit policies
└── services/            # Service objects
```

### Tłumaczenia (i18n)

Wszystkie teksty UI są tłumaczalne. Pliki locale:

- `config/locales/pl.yml` — Polski (domyślny)
- `config/locales/en.yml` — English
- `config/locales/uk.yml` — Українська

Modele z tłumaczeniami używają `Translatable` concern z polami `*_i18n` (JSONB).

---

## Wsparcie

- **Dokumentacja**: Ten folder (`docs/`)
- **Issues**: [GitHub Issues](https://github.com/WebgateSystems/lmcore/issues)
- **Email**: [support@webgate.pro](mailto:support@webgate.pro)

---

<p align="center">
  <strong>© 2026 Webgate Systems LTD</strong>
</p>
