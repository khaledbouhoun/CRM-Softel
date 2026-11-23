# Contributing

Thank you for helping improve CRM - Softel. This project is proprietary
software of SOFTEL, so contributions are expected from SOFTEL staff and
authorized collaborators.

## 1. Set up

1. Fork the repository on GitHub (or get write access), then clone it:
   ```bash
   git clone https://github.com/<you>/CRM-Softel.git
   cd CRM-Softel
   ```
2. Install the toolchain from the [README prerequisites](README.md#prerequisites):
   Flutter 3.47 stable and Visual Studio 2022 with C++ desktop tools. Run
   `flutter doctor` to check it.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app against a development backend:
   ```bash
   flutter run -d windows
   ```
   Then set the server URL under **Settings → Connection**.

No `.env` file is needed. Never commit server addresses, credentials or
customer data.

## 2. Branches

Create a branch from `main`:

| Prefix | Use |
|---|---|
| `feature/<short-name>` | New functionality |
| `fix/<short-name>` | Bug fixes |
| `docs/<short-name>` | Documentation only |
| `chore/<short-name>` | Tooling, dependencies, cleanup |

## 3. Commits

Use [Conventional Commits](https://www.conventionalcommits.org/), with the
feature module as scope when relevant:

```text
feat(prospects): add city filter
fix(follow-ups): cap completion date to current time
docs: update deployment guide
```

## 4. Coding conventions

- Follow `analysis_options.yaml` (`flutter_lints`) and format with `dart format`.
- **Respect the layers.** Pages and widgets talk only to controllers.
  Controllers depend on `domain/` repository interfaces. Only `data/` knows
  about `ApiClient`, JSON and endpoints.
- Add new paths to `lib/core/network/api_endpoints.dart`. Don't hard-code URLs.
- Throw or propagate `ApiException`. Expose loading and error state through `LoadState`.
- **No hard-coded UI strings.** Add keys to all three ARB files in `lib/l10n/`
  (`app_fr.arb` is the template) and check the layout in Arabic (RTL).
- No `print`. Use `debugPrint`, ideally guarded by `kDebugMode`.
- When a field mapping or client-side behaviour changes, update
  [docs/API_CONTRACT.md](docs/API_CONTRACT.md).

## 5. Tests

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
flutter test
```

- Model changes: add JSON round-trip tests in `test/models/`.
- Repository changes: use `test/helpers/mock_http_adapter.dart`.
- Controller logic: add tests in `test/controllers/` with fake repositories.

## 6. Pull requests

1. Rebase on the latest `main`.
2. Make sure analyze, format and tests pass locally.
3. Open a PR describing **what** changed and **why**. Add screenshots for UI
   changes and note any backend or API dependency.
4. Keep PRs focused. Unrelated refactors belong in separate PRs.
5. A maintainer reviews and merges. Don't force-push to `main`.

## 7. Reporting issues

Use GitHub Issues for bugs and feature requests. For security problems,
follow [SECURITY.md](SECURITY.md) instead of opening a public issue.
