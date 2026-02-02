# API Documentation

## Przegląd

LibreMedia udostępnia REST API dla aplikacji mobilnych i integracji zewnętrznych.

- **Base URL**: `https://api.libremedia.org/api/v1`
- **Format**: JSON
- **Autentykacja**: JWT Bearer Token
- **Wersjonowanie**: URL prefix (`/api/v1/`)

---

## Autentykacja

### Rejestracja

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "securepassword123",
    "password_confirmation": "securepassword123",
    "username": "username",
    "first_name": "Jan",
    "last_name": "Kowalski"
  }
}
```

**Response** (201 Created):
```json
{
  "status": "success",
  "message": "Account created. Please check your email to confirm.",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "username": "username"
  }
}
```

### Logowanie

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "securepassword123"
  }
}
```

**Response** (200 OK):
```json
{
  "status": "success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "username": "username",
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

**Header** (for subsequent requests):
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

### Wylogowanie

```http
DELETE /api/v1/auth/logout
Authorization: Bearer <token>
```

---

## Endpoints

### Posts

#### Lista postów

```http
GET /api/v1/posts
```

**Query Parameters**:
| Parametr | Typ | Opis |
|----------|-----|------|
| `page` | integer | Numer strony (domyślnie 1) |
| `per_page` | integer | Elementów na stronę (max 50) |
| `category` | string | Slug kategorii |
| `tag` | string | Slug tagu |
| `author` | string | Username autora |
| `status` | string | Status (published/draft) |

**Response**:
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "type": "post",
      "attributes": {
        "title": "Tytuł artykułu",
        "excerpt": "Krótki opis...",
        "slug": "tytul-artykulu",
        "published_at": "2026-02-01T12:00:00Z",
        "views_count": 1234,
        "reactions_count": 56,
        "comments_count": 12
      },
      "relationships": {
        "author": { "id": "...", "username": "autor" },
        "category": { "id": "...", "name": "Kategoria" }
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 100
  }
}
```

#### Szczegóły posta

```http
GET /api/v1/posts/:slug
```

#### Tworzenie posta

```http
POST /api/v1/posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "post": {
    "title": "Nowy artykuł",
    "content": "<p>Treść artykułu...</p>",
    "excerpt": "Krótki opis",
    "category_id": "550e8400-e29b-41d4-a716-446655440000",
    "tag_ids": ["...", "..."],
    "visibility": "public",
    "status": "draft"
  }
}
```

#### Aktualizacja posta

```http
PATCH /api/v1/posts/:slug
Authorization: Bearer <token>
```

#### Publikacja posta

```http
POST /api/v1/posts/:slug/publish
Authorization: Bearer <token>
```

#### Usunięcie posta

```http
DELETE /api/v1/posts/:slug
Authorization: Bearer <token>
```

---

### Videos

#### Lista wideo

```http
GET /api/v1/videos
```

#### Szczegóły wideo

```http
GET /api/v1/videos/:slug
```

#### Tworzenie wideo

```http
POST /api/v1/videos
Authorization: Bearer <token>
Content-Type: multipart/form-data

title: Tytuł wideo
description: Opis wideo
youtube_url: https://youtube.com/watch?v=...
# LUB
video_file: [binary]
```

---

### Users

#### Profil użytkownika

```http
GET /api/v1/users/:username
```

**Response**:
```json
{
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "username",
    "first_name": "Jan",
    "last_name": "Kowalski",
    "bio": "Opis profilu...",
    "avatar_url": "https://...",
    "verified": true,
    "followers_count": 1234,
    "following_count": 567,
    "posts_count": 89
  }
}
```

#### Obserwowanie użytkownika

```http
POST /api/v1/users/:username/follow
Authorization: Bearer <token>
```

#### Przestanie obserwować

```http
DELETE /api/v1/users/:username/unfollow
Authorization: Bearer <token>
```

---

### Profile (własny profil)

#### Pobranie profilu

```http
GET /api/v1/profile
Authorization: Bearer <token>
```

#### Aktualizacja profilu

```http
PATCH /api/v1/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "user": {
    "first_name": "Jan",
    "last_name": "Kowalski",
    "bio": "Nowy opis...",
    "locale": "pl",
    "timezone": "Europe/Warsaw"
  }
}
```

---

### Subscriptions

#### Lista subskrypcji

```http
GET /api/v1/subscriptions
Authorization: Bearer <token>
```

#### Tworzenie subskrypcji

```http
POST /api/v1/subscriptions
Authorization: Bearer <token>
Content-Type: application/json

{
  "subscription": {
    "creator_id": "550e8400-e29b-41d4-a716-446655440000",
    "price_plan_id": "550e8400-e29b-41d4-a716-446655440001",
    "payment_method_id": "pm_..."
  }
}
```

#### Anulowanie subskrypcji

```http
POST /api/v1/subscriptions/:id/cancel
Authorization: Bearer <token>
```

---

### Donations

#### Lista darowizn

```http
GET /api/v1/donations
Authorization: Bearer <token>
```

#### Tworzenie darowizny

```http
POST /api/v1/donations
Authorization: Bearer <token>
Content-Type: application/json

{
  "donation": {
    "recipient_id": "550e8400-e29b-41d4-a716-446655440000",
    "amount_cents": 1000,
    "currency": "PLN",
    "message": "Dzięki za świetne treści!",
    "payment_method_id": "pm_..."
  }
}
```

---

### Notifications

#### Lista powiadomień

```http
GET /api/v1/notifications
Authorization: Bearer <token>
```

#### Oznaczenie jako przeczytane

```http
POST /api/v1/notifications/:id/read
Authorization: Bearer <token>
```

#### Oznaczenie wszystkich jako przeczytane

```http
POST /api/v1/notifications/mark_all_read
Authorization: Bearer <token>
```

---

### Categories

```http
GET /api/v1/categories
GET /api/v1/categories/:slug
```

---

### Tags

```http
GET /api/v1/tags
GET /api/v1/tags/:slug
```

---

## Kody błędów

| Kod | Opis |
|-----|------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 422 | Unprocessable Entity |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

### Format błędu

```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": {
    "email": ["has already been taken"],
    "password": ["is too short (minimum is 8 characters)"]
  }
}
```

---

## Rate Limiting

| Endpoint | Limit |
|----------|-------|
| Auth | 5 req/min |
| API (auth) | 100 req/min |
| API (guest) | 30 req/min |

Nagłówki odpowiedzi:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1706800000
```

---

## Paginacja

Wszystkie listy są paginowane. Parametry:

| Parametr | Domyślnie | Max |
|----------|-----------|-----|
| `page` | 1 | - |
| `per_page` | 25 | 50 |

Meta w odpowiedzi:
```json
{
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 250,
    "per_page": 25
  }
}
```

---

## Swagger / OpenAPI

Po uruchomieniu serwera dokumentacja Swagger jest dostępna pod:

```
http://localhost:3000/api-docs/index.html
```

Plik OpenAPI:
```
docs/swagger/v1/swagger.yaml
```

Regenerowanie:
```bash
bundle exec rake rswag:specs:swaggerize
```

---

## Powiązane dokumenty

- [architecture.md](architecture.md) — Architektura systemu
- [database.md](database.md) — Struktura bazy danych
