# QO'SHNI — Architecture

## Goals

- One codebase for Android and iOS
- Feature modules that can grow independently
- Clear boundaries: UI never owns business rules or I/O
- Ready for map, marketplace, wallet, AI, courier, etc. **later**

## Layers

| Layer | Responsibility |
|-------|----------------|
| **presentation** | Pages, widgets, controllers that only orchestrate UI |
| **domain** | Entities, repository interfaces, use cases (pure Dart) |
| **data** | DTOs, remote/local sources, repository implementations |
| **core** | Shared config, errors, logging, networking, theme, l10n |
| **di** | Composition root (`get_it`) |
| **routing** | Navigation graph (`go_router`) |
| **services** | Cross-cutting service contracts |

Dependency rule: **presentation → domain ← data**. `data` and `presentation` must not import each other.

## Flavors

Entry files call `bootstrap(AppEnvironment.*)` which builds `AppConfig` and registers DI.

## Adding a feature

1. Create `lib/features/<name>/{presentation,domain,data}`
2. Put contracts in `domain`
3. Implement in `data` (use `ApiClient`, map errors via `ErrorHandler`)
4. Register factories in `configureDependencies`
5. Add routes in `AppRouter`

## Explicit non-goals (this phase)

- No marketplace / map / wallet / AI screens
- No fake API responses
- No state-management framework beyond `ChangeNotifier` for theme/locale
