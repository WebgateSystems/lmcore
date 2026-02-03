# System użytkowników i ról

## Przegląd

LibreMedia implementuje zaawansowany system ról z obsługą:
- **Ról globalnych** — obowiązujących w całej aplikacji
- **Ról kontekstualnych** — przypisanych do konkretnego bloga/twórcy
- **Hierarchii uprawnień** — role z wyższym priorytetem mogą więcej
- **Wygasających przypisań** — role mogą mieć datę wygaśnięcia

---

## Model danych

### Diagram relacji

```
User ──┬── RoleAssignment ──── Role
       │         │
       │         └── scope (polymorphic → User/Blog)
       │
       └── granted_by (User)
```

### Tabela `roles`

| Kolumna | Typ | Opis |
|---------|-----|------|
| `id` | uuid | Primary key |
| `name` | string | Nazwa wyświetlana |
| `name_i18n` | jsonb | Nazwa (wielojęzyczna) |
| `slug` | string | Unikalny identyfikator (np. `super-admin`) |
| `description_i18n` | jsonb | Opis (wielojęzyczny) |
| `permissions` | jsonb | Tablica uprawnień (np. `["manage_users", "manage_content"]`) |
| `priority` | integer | Priorytet roli (wyższy = więcej uprawnień) |
| `system_role` | boolean | Czy rola systemowa (nieusuwalna) |

### Tabela `role_assignments`

| Kolumna | Typ | Opis |
|---------|-----|------|
| `id` | uuid | Primary key |
| `user_id` | uuid | FK → users |
| `role_id` | uuid | FK → roles |
| `scope_type` | string | Typ zakresu (nil = globalna, `User` = blog twórcy) |
| `scope_id` | uuid | ID zakresu (np. ID właściciela bloga) |
| `granted_by_id` | uuid | FK → users (kto przyznał rolę) |
| `expires_at` | datetime | Data wygaśnięcia (nil = bezterminowo) |
| `created_at` | datetime | Data przyznania |

**Unikalny indeks**: `[user_id, role_id, scope_type, scope_id]`

---

## Role systemowe

| Rola | Slug | Priorytet | Uprawnienia |
|------|------|-----------|-------------|
| **Super Admin** | `super-admin` | 100 | `["*"]` — pełny dostęp |
| **Admin** | `admin` | 90 | `["manage_users", "manage_content", "manage_settings"]` |
| **Moderator** | `moderator` | 50 | `["moderate_comments", "moderate_content"]` |
| **Author** | `author` | 30 | `["create_content", "edit_own_content"]` |
| **User** | `user` | 10 | `["comment", "react"]` |
| **Guest** | `guest` | 0 | Brak — tylko publiczne treści |

---

## Role globalne vs kontekstualne

### Role globalne

Przypisane bez zakresu (`scope_type = nil`). Obowiązują w całej aplikacji.

```ruby
# Przykład: Admin globalny
user.has_role?("admin")  # sprawdza globalną rolę
user.admin?              # skrót dla has_role?("admin") || has_role?("super-admin")
```

### Role kontekstualne

Przypisane do konkretnego bloga/twórcy. Obowiązują tylko w kontekście tego bloga.

```ruby
# Przykład: Moderator na blogu użytkownika "creator"
user.has_role?("moderator", scope: creator)  # sprawdza rolę w kontekście
user.can_moderate?(creator)                   # skrót dla sprawdzenia uprawnień
```

---

## Hierarchia uprawnień

Role są hierarchiczne — wyższy `priority` oznacza więcej uprawnień:

```
super-admin (100) > admin (90) > moderator (50) > author (30) > user (10) > guest (0)
```

Metoda `has_role_with_priority?` sprawdza czy użytkownik ma rolę o co najmniej danym priorytecie:

```ruby
user.has_role_with_priority?(50)  # true jeśli moderator lub wyżej
```

---

## API modelu User

### Sprawdzanie ról

```ruby
# Globalne role
user.super_admin?           # czy super admin?
user.admin?                 # czy admin lub super admin?
user.author?                # czy autor?
user.moderator?             # czy moderator?

# Sprawdzanie konkretnej roli
user.has_role?("admin")                      # globalna rola
user.has_role?("moderator", scope: creator)  # kontekstualna rola

# Sprawdzanie priorytetu
user.has_role_with_priority?(50)             # czy min. moderator?

# Najwyższa rola
user.highest_role           # zwraca obiekt Role
user.highest_role(scope: creator)  # najwyższa rola w kontekście
```

### Przypisywanie ról

```ruby
# W kontrolerze admin
user.role_assignments.create!(
  role: Role.find_by(slug: "moderator"),
  scope: creator,           # opcjonalne - dla roli kontekstualnej
  granted_by: current_user,
  expires_at: 1.month.from_now  # opcjonalne
)
```

---

## Autoryzacja (Pundit)

### Przykład policy z rolami

```ruby
# app/policies/admin/post_policy.rb
class Admin::PostPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def create?
    user&.admin? || user&.author?
  end

  def update?
    user&.admin? || record.author == user
  end

  def destroy?
    user&.super_admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(author: user)
      end
    end
  end
end
```

### Kontekstualne uprawnienia

```ruby
# app/policies/blog_post_policy.rb
class BlogPostPolicy < ApplicationPolicy
  def moderate?
    user&.admin? || user&.can_moderate?(record.author)
  end
end
```

---

## Panel administracyjny

### Zarządzanie rolami

Dostępne pod `/admin/users/:id` dla administratorów:

1. **Przypisywanie ról globalnych** — Super Admin może nadawać wszystkie role
2. **Przypisywanie ról kontekstualnych** — twórca może nadawać role na swoim blogu
3. **Ustawianie wygaśnięcia** — role mogą być czasowe
4. **Historia przypisań** — kto i kiedy nadał rolę

### Impersonacja

Super Admin może zalogować się jako inny użytkownik:

```
POST /admin/users/:id/impersonate
DELETE /admin/stop_impersonating
```

---

## Statusy użytkownika

Niezależnie od ról, użytkownik ma status:

| Status | Opis |
|--------|------|
| `pending` | Oczekuje na potwierdzenie email |
| `active` | Aktywny, może korzystać z platformy |
| `suspended` | Zawieszony przez admina |
| `deleted` | Soft-deleted (Discard gem) |

```ruby
user.activate!      # status = active
user.suspend!       # status = suspended
user.soft_delete!   # status = deleted, discarded_at = now
```

---

## Powiązane dokumenty

- [database.md](../database.md) — Struktura bazy danych
- [architecture.md](../architecture.md) — Architektura systemu
- [api.md](../api.md) — Dokumentacja API
