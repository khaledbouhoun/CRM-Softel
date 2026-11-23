# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
The project uses [Semantic Versioning](https://semver.org/).

No release has been tagged yet. `pubspec.yaml` declares version `1.0.0+1`,
and the entries below are reconstructed from the Git history.

## [Unreleased]

### Added
- Project documentation: architecture, contributing, security policy,
  deployment guide, and a README for the `tool/` scripts.
- `.editorconfig`.

### Changed
- Rewrote `README.md` to reflect every implemented module and the actual
  toolchain (Flutter 3.47 / Dart 3.13), build output path and default settings.
- `.gitignore`: `pubspec.lock` is no longer pattern-ignored, and
  `installer/Output/` and `__pycache__/` are ignored.

### Fixed
- Removed a leftover `print` of the follow-up completion response.

## [1.0.0] - 2026-11-23 (not tagged)

Current state of `main`; the app version is `1.0.0+1`.

### Added
- **Analytics** hub with charts (`fl_chart`). *(2026-11-23)*
- **Workstation hub**: team presence and editable employee identity. *(2026-11-23)*
- **Billing**: subscriptions, renewal quotes, invoices, mark-as-paid, receipts. *(2026-11-23)*
- Product catalog with multilingual content and thumbnails, plus `google_fonts`
  typography (Quicksand, Alexandria). *(2026-11-23)*
- Product **packs** with composition rules; product **trials** for customers. *(2026-11-19 – 11-21)*
- **Releases**: product version tracking with installer upload and download. *(2026-11-19)*
- **After-sales interventions**: chat timeline, attachments, closure dialogs. *(2026-11-16 – 11-19)*
- **Scheduling**: calendar, appointments, training, customer-portal requests. *(2026-11-16)*
- **Customers**: prospect conversion and customer profile. *(2026-11-16)*
- Server-driven **workflow settings** with contextual help. *(2026-11-16)*
- Employee identity, heartbeat and `X-Employee-Name` write auditing. *(2026-11-16)*
- Inno Setup installer script. *(2026-11-16)*
- Unit, repository, controller and widget test suites. *(2026-11-16)*
- Localization tooling scripts in `tool/`. *(2026-11-16)*
- Branding assets and app metadata ("CRM - Softel"). *(2026-11-11)*
- WhatsApp links for prospects and follow-ups. *(2026-11-11)*
- Configurable prospect form options. *(2026-11-10)*
- Initial application: dashboard, prospects, Kanban pipeline, follow-ups,
  activities, products, sales stages, loss reasons, connection settings,
  FR/EN/AR localization with RTL, light/dark themes. *(2026-11-09)*

### Changed
- Refreshed theme, shared widgets, app shell and navigation. *(2026-11-23)*

### Fixed
- Follow-up completion date is capped to the current time when the due date
  is in the future. *(2026-11-16)*
- Activity-to-prospect association check in the model and link controller. *(2026-11-16)*
