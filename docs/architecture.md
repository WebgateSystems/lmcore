# Architektura LibreMedia

## Przegląd

LibreMedia to monolityczna aplikacja Ruby on Rails z wydzielonym API REST dla aplikacji mobilnych i integracji zewnętrznych.

## Warstwy aplikacji

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Web Views     │  │   API (JSON)    │  │   WebSocket     │  │
│  │   (Slim/HTML)   │  │   (REST v1)     │  │   (ActionCable) │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                      Application Layer                           │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Controllers   │  │    Policies     │  │    Services     │  │
│  │                 │  │    (Pundit)     │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                       Domain Layer                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │     Models      │  │    Concerns     │  │   Validators    │  │
│  │  (ActiveRecord) │  │                 │  │                 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                    Infrastructure Layer                          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐│
│  │PostgreSQL│ │  Redis   │ │Elastics. │ │ Sidekiq  │ │ Stripe ││
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## Komponenty

### 1. Warstwa prezentacji

#### Web Views (Slim)
- Renderowanie po stronie serwera z Hotwire (Turbo + Stimulus)
- Layout: `landing` (strona główna), `application` (zalogowani użytkownicy)
- Responsywny design z SCSS i CSS Grid/Flexbox

#### API REST (v1)
- Namespace: `/api/v1/*`
- Autentykacja: JWT (Devise + devise-jwt)
- Format: JSON
- Wersjonowanie: URL prefix (`/api/v1/`)

#### WebSocket (Action Cable)
- Powiadomienia w czasie rzeczywistym
- Kanały: `NotificationsChannel`, `CommentsChannel`

### 2. Warstwa aplikacji

#### Controllers
- **Web**: Dziedziczą po `ApplicationController`
- **API**: Dziedziczą po `Api::V1::BaseController`
- Namespace `Admin::` dla panelu administracyjnego

#### Policies (Pundit)
- Autoryzacja na poziomie zasobów
- Każdy model ma odpowiadającą policy (np. `PostPolicy`)
- Scopes dla list (`policy_scope(Post)`)

#### Services
- Wydzielona logika biznesowa
- Konwencja nazewnictwa: `VerbNounService` (np. `CreateSubscriptionService`)

### 3. Warstwa domenowa

#### Models
Główne modele:

| Model | Opis |
|-------|------|
| `User` | Użytkownicy systemu |
| `Post` | Artykuły tekstowe |
| `Video` | Materiały wideo |
| `Photo` | Galerie zdjęć |
| `Page` | Strony statyczne |
| `Category` | Kategorie treści |
| `Tag` | Tagi (folksonomia) |
| `Comment` | Komentarze |
| `Reaction` | Reakcje (like, love, etc.) |
| `Follow` | Obserwacje użytkowników |
| `Subscription` | Subskrypcje premium |
| `Payment` | Historia płatności |
| `Donation` | Darowizny |
| `Notification` | Powiadomienia |
| `Partner` | Partnerzy medialni |

#### Concerns (moduły współdzielone)

| Concern | Opis | Używany przez |
|---------|------|---------------|
| `Sluggable` | Automatyczne generowanie slug | Post, Video, Photo, Category, Tag |
| `Translatable` | Pola wielojęzyczne (JSONB) | Post, Category, Partner |
| `Publishable` | Status publikacji | Post, Video, Photo |
| `Reactable` | Reakcje (polimorficzne) | Post, Video, Photo, Comment |
| `Commentable` | Komentarze (polimorficzne) | Post, Video, Photo |
| `Taggable` | Tagowanie (polimorficzne) | Post, Video, Photo |

### 4. Warstwa infrastruktury

#### PostgreSQL
- Główna baza danych
- UUID jako primary key
- JSONB dla danych strukturalnych (tłumaczenia, metadane)

#### Redis
- Cache (Rails.cache)
- Session store
- Sidekiq backend
- Action Cable backend

#### Elasticsearch
- Wyszukiwanie pełnotekstowe
- Indeksowane modele: `Post`, `Video`, `Photo`, `User`
- Gem: Searchkick

#### Sidekiq
- Przetwarzanie w tle
- Kolejki: `default`, `mailers`, `low`, `critical`
- UI: `/sidekiq` (tylko admin)

#### Stripe
- Płatności kartowe
- Subskrypcje (recurring)
- Darowizny (one-time)

---

## Diagram przepływu żądania

```
                          ┌──────────────┐
                          │    Client    │
                          │ (Browser/App)│
                          └──────┬───────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │    Nginx     │
                          │ (Reverse Pr.)│
                          └──────┬───────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │    Puma      │
                          │  (App Server)│
                          └──────┬───────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │   Router     │
                          │ (config/routes)
                          └──────┬───────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
       ┌────────────┐     ┌────────────┐     ┌────────────┐
       │ Middleware │     │   before_  │     │  Pundit    │
       │  (Rack)    │     │   action   │     │ authorize  │
       └─────┬──────┘     └─────┬──────┘     └─────┬──────┘
              │                  │                  │
              └──────────────────┼──────────────────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │  Controller  │
                          │   Action     │
                          └──────┬───────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
       ┌────────────┐     ┌────────────┐     ┌────────────┐
       │   Model    │     │  Service   │     │   Cache    │
       │            │     │            │     │            │
       └─────┬──────┘     └─────┬──────┘     └─────┬──────┘
              │                  │                  │
              └──────────────────┼──────────────────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │    View      │
                          │  (Slim/JSON) │
                          └──────┬───────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │   Response   │
                          └──────────────┘
```

---

## Autentykacja i autoryzacja

### Autentykacja

| Kanał | Metoda | Gem |
|-------|--------|-----|
| Web | Session cookie | Devise |
| API | JWT Bearer token | devise-jwt |

### Autoryzacja (Pundit)

```ruby
# app/policies/post_policy.rb
class PostPolicy < ApplicationPolicy
  def show?
    record.published? || record.author == user || user&.admin?
  end

  def update?
    record.author == user || user&.admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.published.or(scope.where(author: user))
      end
    end
  end
end
```

---

## Bezpieczeństwo

### Nagłówki HTTP (secure_headers gem)

```ruby
SecureHeaders::Configuration.default do |config|
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.content_security_policy = { ... }
end
```

### CSRF Protection
- Token CSRF dla formularzy
- API: wyłączone (stateless JWT)

### Rate Limiting
- Rack::Attack dla ochrony przed DDoS/brute-force

---

## Skalowanie

### Horyzontalne
- Wiele instancji Puma za load balancerem
- Sesje w Redis (współdzielone między instancjami)
- Sidekiq jako osobne procesy

### Pionowe
- PostgreSQL: replika read-only
- Redis: cluster mode
- Elasticsearch: cluster wielowęzłowy

---

## Powiązane dokumenty

- [database.md](database.md) — Szczegóły struktury bazy danych
- [api.md](api.md) — Dokumentacja API
- [deployment.md](deployment.md) — Instrukcje wdrożenia
