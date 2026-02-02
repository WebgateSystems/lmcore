# LibreMedia

[![Ruby](https://img.shields.io/badge/Ruby-3.4.6-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1.2-D30001?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![License: SACL](https://img.shields.io/badge/License-SACL--1.0-orange.svg)](LICENSE.md)

---

Languages: [Polski (default)](README.md) · **English** · [Українська](README.uk.md)

---

## What is LibreMedia?

**LibreMedia** is an independent multimedia SaaS platform for creators, journalists, and opinion leaders who value **freedom of speech** and **media independence**.

The platform enables:
- 📹 Publishing multimedia content (video, photos, articles)
- 💰 Monetization through subscriptions and donations
- 👥 Building communities around democratic values
- 🌍 Global reach with multilingual interface (PL, EN, UK, LT, DE, FR, ES)

> **Free media means independent media.**  
> True independence requires financial independence — when conscious users support creators directly.

---

## Why is the source code public?

LibreMedia is a **commercial SaaS platform** with **publicly available source code**.

The code is public to ensure:

- 🔍 **Transparency and security** — anyone can audit the code and verify there are no backdoors or spyware
- 🧠 **Technical openness** — architecture and implementation decisions are visible
- 🤝 **Community contributions** — pull requests with fixes and improvements are welcome

### Is LibreMedia open source?

**No.**

LibreMedia is **source-available**, not open source under the OSI definition. This distinction is intentional and clearly communicated. Details in [LICENSE.md](LICENSE.md).

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/README.md](docs/README.md) | Main technical documentation |
| [docs/architecture.md](docs/architecture.md) | System architecture |
| [docs/api.md](docs/api.md) | API documentation |
| [docs/database.md](docs/database.md) | Database structure and ERD |
| [docs/deployment.md](docs/deployment.md) | Deployment instructions |
| [LICENSE.md](LICENSE.md) | SACL-1.0 License |

---

## Requirements (local)

- **Ruby**: `3.4.6` (see `.ruby-version`)
- **PostgreSQL**: 15+
- **Node.js**: 24+ (see `.node-version` / `.nvmrc`)
- **Yarn**: 1.22+
- **Redis**: 7+ (for Sidekiq)
- **Elasticsearch**: 8.x (optional, for search)

## Quick Start

### 1. Install dependencies

```bash
# Ruby
bundle install

# JavaScript
yarn install
```

### 2. Set up database

```bash
bin/rails db:prepare
```

### 3. Load sample data (development)

```bash
bin/rails db:seed
```

### 4. Start the server

```bash
bin/dev
```

The application will be available at `http://localhost:3000`

---

## Configuration

Default settings are in `config/settings.yml`. Key environment variables:

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection URL |
| `REDIS_URL` | Redis connection URL |
| `DEVISE_JWT_SECRET_KEY` | JWT secret for API |
| `ELASTICSEARCH_URL` | Elasticsearch URL (optional) |
| `STRIPE_*` | Stripe payment keys |
| `SMTP_*` | Email configuration |

---

## Tests

### Unit tests (RSpec)

```bash
bundle exec rspec
```

### Code coverage

After running tests, the coverage report is generated at `coverage/index.html`.

---

## Services / Components

- **Sidekiq** — background job processing
- **Elasticsearch** — full-text search
- **Stripe** — payments and subscriptions
- **Action Cable** — WebSocket for real-time notifications

---

## Deployment

Deployments are done via Capistrano:

```bash
cap staging deploy
cap production deploy
```

Details in [docs/deployment.md](docs/deployment.md).

---

## Contributing

Pull requests are welcome!

By submitting a contribution, you agree that it may be incorporated into the commercial LibreMedia product without additional compensation.

Details in [LICENSE.md](LICENSE.md).

---

## Ownership

LibreMedia is developed and operated by **Webgate Systems LTD (United Kingdom)**.

| | |
|---|---|
| **Website** | [webgate.pro](https://webgate.pro) |
| **Email** | [legal@webgate.pro](mailto:legal@webgate.pro) |
| **GitHub** | [github.com/WebgateSystems/lmcore](https://github.com/WebgateSystems/lmcore) |

---

<p align="center">
  <strong>© 2026 Webgate Systems LTD</strong><br>
  <em>LibreMedia — Free Speech, Free Media</em>
</p>
