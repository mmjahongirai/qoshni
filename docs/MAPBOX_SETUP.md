# Mapbox (minimal integration)

QO'SHNI uses the official [`mapbox_maps_flutter`](https://pub.dev/packages/mapbox_maps_flutter) SDK (**3.33.0**).

## Access token

Use a **public** Mapbox token (`pk…`) with the minimum scopes required for map tiles. Never commit tokens or use secret `sk` tokens in the client.

Configure at compile time:

```bash
flutter run -t lib/main_development.dart --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_PUBLIC_PK_TOKEN
```

```bash
flutter build web --release -t lib/main_development.dart --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_PUBLIC_PK_TOKEN
```

If `MAPBOX_ACCESS_TOKEN` is missing, the app starts normally and shows a configuration placeholder instead of a live map.

## Vercel

Add environment variable **`MAPBOX_ACCESS_TOKEN`** in the Vercel project settings. The build script `scripts/vercel-build-web.sh` forwards it to Flutter via `--dart-define`. Deploys without the variable still build successfully; the map area shows the placeholder until a token is configured.

## Out of scope (Phase 17)

GPS, nearby business markers, routing, geocoding, and backend map data are not part of this checkpoint.
