# Productiv

Team-built full-stack productivity platform — a group project for the University of Sheffield
Genesys module (COM4525, 45 credits).

Productiv combines personal and shared task management with focus tools, gamification and
analytics in a multi-role web application.

> **Team project note:** this codebase was developed by a team. This repository archives the full
> team source for reference and portfolio context; no subsystem is attributed to an individual
> contributor here.

## Stack

| Layer | Technology |
|---|---|
| Language | Ruby 3.4.5 |
| Framework | Rails / ActiveRecord 8.0.5 |
| Database | PostgreSQL 16 |
| Views | Haml (126 templates), Bootstrap, Turbo/Stimulus |
| Assets | Shakapacker 9.5 (Webpack/Yarn) |
| Authentication | Devise + Devise Invitable |
| Authorisation | CanCanCan (`Ability`) |
| Analytics | Ahoy + Groupdate + Chartkick |
| Background jobs | Delayed Job + Whenever |
| AI | Google Gemini (`gemini-2.5-flash`) via `Net::HTTP`, with a labelled demo fallback |
| Monitoring | Sentry |
| Deployment | Capistrano / epi_deploy |

## Features

Multi-role product with three namespaces:

- **Public** — landing page, registration, posts, reviews, interests.
- **Subscriber** — individual tasks and history, shared projects/tasks, assignments, invitations,
  notifications, a Pomodoro focus screen, shop/items/plants gamification, and AI task breakdown.
- **Reporter** — landing-page, feature-engagement, gamification and user-growth metrics.
- **Admin** — users, posts, reviews, interests and dashboard management.

## Architecture

The codebase separates domain services from controllers:

- `app/controllers` — 30 controllers across `public`, `admin`, `reporter` and `subscriber` namespaces.
- `app/models` — 22 models covering teams, tasks, invitations, notifications, items, plants, points and metrics.
- `app/services` — domain services for team, task, notification, assignment and point workflows.
- `app/services/ai` — Gemini client, prompt and fallback service.
- `db/migrate` — 44 migrations across 21 tables.

## AI task breakdown

The AI integration calls the Google Generative Language API (`gemini-2.5-flash`) using the
`GEMINI_API_KEY` environment variable (or Rails credentials). A labelled fallback service returns a
pre-written breakdown when the "Demo AI Task" is used and Gemini is unavailable, for demo reliability.
Error handling includes service-specific and general rescue paths with Sentry capture.

## Testing and CI

- 98 RSpec spec files (RSpec, Capybara, Selenium, FactoryBot, WebMock, VCR, SimpleCov, `rspec-benchmark`).
- 23 workload-oriented performance examples across 14 performance files.
- GitLab CI defines `setup`, `test`, `security` and `lint` stages (PostgreSQL 16 + Selenium Chrome):
  Bundler/Yarn setup, RSpec, Bundler Audit, Brakeman, RuboCop and ESLint.

## Getting started

```bash
bundle install
yarn install

# database
sudo service postgresql start
cp config/database-sample.yml config/database.yml
rails db:create db:migrate db:seed

# run
bundle exec rails s
bin/shakapacker-dev-server
```

See `GETTING_STARTED.md` for the Genesys deployment, Sentry and mail configuration.

## Demo accounts

Seeded demo accounts use non-reusable placeholder credentials (local development only):

| Role | Email | Password |
|---|---|---|
| Admin | admin1@example.com / admin2@example.com | Password@1234 |
| Reporter | reporter1@example.com … reporter3@example.com | Password@1234 |
| Subscriber | subscriber1@example.com … subscriber3@example.com | Password@1234 |

## Ownership and licence

Team project — no licence is asserted here. Third-party dependencies retain their own notices.
Public redistribution would require team and university approval.
