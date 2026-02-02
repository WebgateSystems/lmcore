# Monetyzacja

System monetyzacji LibreMedia umożliwia twórcom zarabianie na swojej pracy.

---

## Przegląd

LibreMedia oferuje dwa główne mechanizmy monetyzacji:

1. **Subskrypcje** — cykliczne płatności za dostęp do treści premium
2. **Darowizny** — jednorazowe wsparcie finansowe

---

## Subskrypcje

### Model biznesowy

```
Twórca → definiuje plany cenowe → Użytkownik subskrybuje → Stripe przetwarza płatność
```

### Plany cenowe (PricePlan)

Każdy twórca może zdefiniować własne plany:

| Pole | Opis |
|------|------|
| `name_i18n` | Nazwa planu (wielojęzyczna) |
| `description_i18n` | Opis korzyści |
| `price_cents` | Cena w groszach |
| `currency` | Waluta (PLN, USD, EUR) |
| `interval` | Okres (month/year) |

### Przykład

```ruby
PricePlan.create!(
  creator: user,
  name_i18n: { pl: "Premium", en: "Premium" },
  description_i18n: { 
    pl: "Dostęp do wszystkich treści", 
    en: "Access to all content" 
  },
  price_cents: 1999,  # 19.99 PLN
  currency: "PLN",
  interval: "month"
)
```

### Stripe Integration

```ruby
# Tworzenie subskrypcji
class CreateSubscriptionService
  def call(user:, creator:, price_plan:, payment_method_id:)
    # 1. Attach payment method to customer
    Stripe::PaymentMethod.attach(payment_method_id, customer: user.stripe_customer_id)
    
    # 2. Create subscription
    stripe_subscription = Stripe::Subscription.create(
      customer: user.stripe_customer_id,
      items: [{ price: price_plan.stripe_price_id }],
      default_payment_method: payment_method_id
    )
    
    # 3. Save locally
    Subscription.create!(
      user: user,
      creator: creator,
      price_plan: price_plan,
      stripe_subscription_id: stripe_subscription.id,
      status: :active,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )
  end
end
```

### Webhooks Stripe

LibreMedia nasłuchuje na webhooks:

| Event | Akcja |
|-------|-------|
| `invoice.paid` | Przedłużenie subskrypcji |
| `invoice.payment_failed` | Oznaczenie jako `past_due` |
| `customer.subscription.deleted` | Anulowanie subskrypcji |

---

## Darowizny

### Model

Jednorazowe wsparcie twórcy:

```ruby
Donation.create!(
  donor: current_user,
  recipient: creator,
  amount_cents: 5000,  # 50 PLN
  currency: "PLN",
  message: "Świetna robota!",
  stripe_payment_intent_id: "pi_..."
)
```

### Stripe Payment Intent

```ruby
class CreateDonationService
  def call(donor:, recipient:, amount_cents:, currency:, message:, payment_method_id:)
    # 1. Create payment intent
    payment_intent = Stripe::PaymentIntent.create(
      amount: amount_cents,
      currency: currency.downcase,
      customer: donor.stripe_customer_id,
      payment_method: payment_method_id,
      confirm: true
    )
    
    # 2. Save donation
    Donation.create!(
      donor: donor,
      recipient: recipient,
      amount_cents: amount_cents,
      currency: currency,
      message: message,
      stripe_payment_intent_id: payment_intent.id,
      status: payment_intent.status == 'succeeded' ? :completed : :pending
    )
  end
end
```

---

## Poziomy dostępu do treści

### ContentVisibility

Treści mogą mieć różne poziomy dostępu:

| Visibility | Opis | Kto widzi |
|------------|------|-----------|
| `public` | Publiczne | Wszyscy |
| `subscribers` | Dla subskrybentów | Subskrybenci twórcy |
| `private` | Prywatne | Tylko autor |

### Implementacja (Pundit Policy)

```ruby
class PostPolicy < ApplicationPolicy
  def show?
    case record.visibility
    when 'public'
      true
    when 'subscribers'
      user&.subscribed_to?(record.author) || owner_or_admin?
    when 'private'
      owner_or_admin?
    end
  end
  
  private
  
  def owner_or_admin?
    record.author == user || user&.admin?
  end
end
```

---

## Prowizje platformy

LibreMedia pobiera prowizję od transakcji:

| Typ | Prowizja |
|-----|----------|
| Subskrypcje | 10% |
| Darowizny | 5% |

Prowizje Stripe (zewnętrzne):
- ~2.9% + 0.30 USD na transakcję

---

## Wypłaty dla twórców

### Model Payout

```ruby
# Planowane do implementacji
class Payout < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  
  # amount_cents: kwota do wypłaty
  # stripe_transfer_id: ID transferu Stripe
  # status: pending/processing/completed/failed
end
```

### Stripe Connect

Twórcy łączą swoje konta bankowe przez Stripe Connect:

1. Twórca rejestruje konto Stripe Connect
2. LibreMedia przekazuje środki po odjęciu prowizji
3. Stripe wypłaca na konto bankowe twórcy

---

## Statystyki i raporty

### Dashboard twórcy

- Przychody miesięczne/roczne
- Liczba aktywnych subskrybentów
- Historia donacji
- Trend wzrostu

### Metryki

```ruby
class CreatorStats
  def initialize(creator)
    @creator = creator
  end
  
  def monthly_revenue
    subscriptions.sum(:price_cents) + donations.sum(:amount_cents)
  end
  
  def active_subscribers
    @creator.subscribers.where(status: :active).count
  end
  
  def churn_rate
    # Procent anulowanych subskrypcji w ostatnim miesiącu
  end
end
```

---

## Powiązane dokumenty

- [../api.md](../api.md) — Endpointy API dla płatności
- [users.md](users.md) — System użytkowników
