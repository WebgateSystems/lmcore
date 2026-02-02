# Deployment LibreMedia

## Przegląd

LibreMedia jest wdrażana za pomocą Capistrano na serwery z Nginx + Puma.

---

## Wymagania serwera

### System operacyjny
- Ubuntu 22.04 LTS lub nowszy
- Debian 11 lub nowszy

### Oprogramowanie
- Ruby 3.4.6 (via rbenv/rvm)
- Node.js 24+ (via nvm)
- PostgreSQL 15+
- Redis 7+
- Nginx
- Certbot (Let's Encrypt)

### Opcjonalne
- Elasticsearch 8.x
- FFmpeg (dla przetwarzania wideo)

---

## Struktura środowisk

| Środowisko | Domena | Branch |
|------------|--------|--------|
| Production | libremedia.org | main |
| Staging | staging.libremedia.org | develop |

---

## Konfiguracja serwera

### 1. Użytkownik deploy

```bash
# Na serwerze
sudo adduser deploy
sudo usermod -aG sudo deploy

# SSH key
sudo mkdir -p /home/deploy/.ssh
sudo cp ~/.ssh/authorized_keys /home/deploy/.ssh/
sudo chown -R deploy:deploy /home/deploy/.ssh
```

### 2. Instalacja Ruby (rbenv)

```bash
# Jako deploy
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install 3.4.6
rbenv global 3.4.6
```

### 3. Instalacja Node.js (nvm)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 24
nvm use 24
npm install -g yarn
```

### 4. PostgreSQL

```bash
sudo apt install postgresql postgresql-contrib libpq-dev
sudo -u postgres createuser -s deploy
sudo -u postgres createdb libremedia_production
```

### 5. Redis

```bash
sudo apt install redis-server
sudo systemctl enable redis-server
```

### 6. Nginx

```bash
sudo apt install nginx
sudo systemctl enable nginx
```

---

## Konfiguracja Capistrano

### Gemfile

```ruby
group :development do
  gem 'capistrano', '~> 3.18'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-bundler'
  gem 'capistrano-yarn'
  gem 'capistrano3-puma'
  gem 'capistrano-sidekiq'
end
```

### Capfile

```ruby
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/yarn'
require 'capistrano/puma'
require 'capistrano/sidekiq'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
```

### config/deploy.rb

```ruby
lock '~> 3.18'

set :application, 'libremedia'
set :repo_url, 'git@github.com:WebgateSystems/lmcore.git'
set :deploy_to, '/var/www/libremedia'

set :rbenv_ruby, '3.4.6'
set :rbenv_type, :user

set :linked_files, %w[
  config/database.yml
  config/master.key
  config/settings.local.yml
  .env
]

set :linked_dirs, %w[
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  public/system
  public/uploads
  storage
  node_modules
]

set :keep_releases, 5

set :puma_init_active_record, true
set :puma_preload_app, true

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after :publishing, :restart
end
```

### config/deploy/production.rb

```ruby
server 'libremedia.org',
  user: 'deploy',
  roles: %w[app db web],
  ssh_options: {
    forward_agent: true,
    auth_methods: %w[publickey]
  }

set :branch, 'main'
set :rails_env, 'production'
```

### config/deploy/staging.rb

```ruby
server 'staging.libremedia.org',
  user: 'deploy',
  roles: %w[app db web],
  ssh_options: {
    forward_agent: true,
    auth_methods: %w[publickey]
  }

set :branch, 'develop'
set :rails_env, 'staging'
```

---

## Konfiguracja Nginx

### /etc/nginx/sites-available/libremedia

```nginx
upstream puma_libremedia {
  server unix:///var/www/libremedia/shared/tmp/sockets/puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name libremedia.org www.libremedia.org;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name libremedia.org www.libremedia.org;

  ssl_certificate /etc/letsencrypt/live/libremedia.org/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/libremedia.org/privkey.pem;

  root /var/www/libremedia/current/public;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location ^~ /packs/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location / {
    proxy_pass http://puma_libremedia;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
  }

  location /cable {
    proxy_pass http://puma_libremedia;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
  }

  client_max_body_size 100M;

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /var/www/libremedia/current/public;
  }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/libremedia /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Konfiguracja Sidekiq (systemd)

### /etc/systemd/system/sidekiq-libremedia.service

```ini
[Unit]
Description=Sidekiq for LibreMedia
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/libremedia/current
ExecStart=/home/deploy/.rbenv/shims/bundle exec sidekiq -e production -C config/sidekiq.yml
ExecReload=/bin/kill -TSTP $MAINPID
Restart=always
RestartSec=10

Environment=RAILS_ENV=production
Environment=MALLOC_ARENA_MAX=2

SyslogIdentifier=sidekiq-libremedia

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable sidekiq-libremedia
sudo systemctl start sidekiq-libremedia
```

---

## Wdrożenie

### Pierwsze wdrożenie

```bash
# Lokalnie
cap production deploy:check
cap production deploy
```

### Kolejne wdrożenia

```bash
cap production deploy
```

### Wycofanie (rollback)

```bash
cap production deploy:rollback
```

---

## Zmienne środowiskowe

Plik `.env` na serwerze (`/var/www/libremedia/shared/.env`):

```bash
RAILS_ENV=production
SECRET_KEY_BASE=...
DATABASE_URL=postgresql://deploy@localhost/libremedia_production
REDIS_URL=redis://localhost:6379/0

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# SMTP
SMTP_ADDRESS=smtp.postmarkapp.com
SMTP_PORT=587
SMTP_USERNAME=...
SMTP_PASSWORD=...
SMTP_DOMAIN=libremedia.org

# Elasticsearch (opcjonalnie)
ELASTICSEARCH_URL=http://localhost:9200

# Sentry (opcjonalnie)
SENTRY_DSN=https://...
```

---

## SSL (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d libremedia.org -d www.libremedia.org
sudo certbot renew --dry-run
```

---

## Backup

### Baza danych

```bash
# Codziennie o 3:00
0 3 * * * /usr/bin/pg_dump -Fc libremedia_production > /var/backups/libremedia/db_$(date +\%Y\%m\%d).dump
```

### Pliki użytkowników

```bash
# Sync do S3
0 4 * * * aws s3 sync /var/www/libremedia/shared/public/uploads s3://libremedia-backups/uploads/
```

---

## Monitoring

### Logwatch

```bash
sudo apt install logwatch
```

### Uptime monitoring

- UptimeRobot
- Pingdom

### Application monitoring

- Sentry (errors)
- New Relic / Scout APM (performance)

---

## Troubleshooting

### Logi

```bash
# Rails
tail -f /var/www/libremedia/shared/log/production.log

# Nginx
tail -f /var/log/nginx/error.log

# Sidekiq
journalctl -u sidekiq-libremedia -f

# Puma
tail -f /var/www/libremedia/shared/log/puma.stdout.log
```

### Restart usług

```bash
sudo systemctl restart nginx
sudo systemctl restart sidekiq-libremedia

# Puma (via Capistrano)
cap production puma:restart
```

### Rails console

```bash
cd /var/www/libremedia/current
RAILS_ENV=production bundle exec rails c
```

---

## Powiązane dokumenty

- [architecture.md](architecture.md) — Architektura systemu
- [infrastructure.md](infrastructure.md) — Szczegóły infrastruktury
