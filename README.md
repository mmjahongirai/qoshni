# QO'SHNI

Production-oriented Flutter foundation for a local services & marketplace
platform (Uzbekistan → world). **Business features are not implemented yet.**

## Stack

- Flutter / Dart (Android + iOS)
- Clean Architecture + feature-first folders
- `go_router` · `get_it` · `dio` · `logger` · `intl` / gen-l10n

## Architecture (short)

```
lib/
  main_*.dart          # flavor entrypoints
  bootstrap/           # startup, DI, error zone
  app/                 # MaterialApp.router
  di/                  # get_it registrations
  routing/             # go_router
  core/                # config, error, logging, network, theme, l10n, responsive
  features/home/       # shell only (presentation + empty domain/data)
  services/            # future cross-cutting contracts
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Run

Add Flutter to PATH (SDK used on this machine: `C:\src\flutter\bin`), then:

```bash
flutter pub get

# Development
flutter run -t lib/main_development.dart

# Staging
flutter run -t lib/main_staging.dart

# Production
flutter run -t lib/main_production.dart
# or
flutter run -t lib/main.dart
```

```bash
flutter analyze
flutter test
```

## Environments

| Flavor        | Entrypoint                 | API base (placeholder)              |
|---------------|----------------------------|-------------------------------------|
| development   | `main_development.dart`    | `https://api.dev.qoshni.uz`         |
| staging       | `main_staging.dart`        | `https://api.staging.qoshni.uz`     |
| production    | `main_production.dart`     | `https://api.qoshni.uz`             |

No real backend calls are made in this phase.
