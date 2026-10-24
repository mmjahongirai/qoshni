# Phase 17 — WP1: Location Foundation & Privacy

## Scope delivered

Bounded foundation for map-related device location: permission handling, transient current-location snapshots, privacy boundaries, and map UI integration on the existing Mapbox route. No backend geospatial APIs, PostGIS, geocoding, or saved-place persistence in this package.

## Reused map integration

| Piece | Path |
| --- | --- |
| Mapbox SDK | `mapbox_maps_flutter` in `pubspec.yaml` |
| Access token | `lib/core/config/mapbox_access_config.dart` |
| Initializer | `lib/core/mapbox/mapbox_initializer.dart` |
| Default camera (Uzbekistan) | `lib/features/home/presentation/map/qoshni_map_defaults.dart` |
| Map widget / placeholder | `lib/features/home/presentation/widgets/qoshni_mapbox_view.dart` |
| Full-screen route | `lib/features/home/presentation/pages/map_placeholder_page.dart` → `RoutePaths.map` |
| Home preview card | `lib/features/home/presentation/widgets/map_preview_card.dart` (unchanged behavior) |

No second map SDK or duplicate routes were added.

## New domain & service boundaries

```
lib/features/location/
  domain/
    qoshni_geo_coordinates.dart          # Validated WGS-84 bounds
    qoshni_location_source.dart          # gps / network / fused / mapSelection
    qoshni_location_kind.dart            # deviceCurrent vs mapSelected
    qoshni_location_permission_status.dart
    qoshni_location_failure.dart
    qoshni_current_location_snapshot.dart  # Transient; not a delivery address
    qoshni_saved_place.dart              # Contract only in WP1
    qoshni_location_provider.dart        # Testable platform adapter
    repositories/qoshni_saved_place_repository.dart  # No implementation yet
  application/
    qoshni_location_service.dart         # Permission + acquisition orchestration
    qoshni_map_location_controller.dart  # Map session UI state
  data/
    geolocator_qoshni_location_provider.dart
    fake_qoshni_location_provider.dart
```

`QoshniSearchLocation` (Phase 16) remains search-filter coordinates only — not device GPS.

## Permission & acquisition behavior

- **No acquisition on app startup or map open.** Only the app-bar **My location** action calls `QoshniMapLocationController.requestDeviceLocation()`.
- **Permission prompt** runs only when acquisition is invoked with `allowPermissionRequest: true` (explicit user action).
- **Session flag** `permissionPromptRequestedThisSession` maps platform “denied before ask” to `notYetRequested` until the user has tapped My location once.
- **States handled:** not yet requested, granted, denied, permanently denied (limited reserved for platforms that expose reduced accuracy).
- **Location services disabled** → failure with localized message; map keeps default viewport.
- **Timeout / unavailable** → typed failures; **Retry** re-runs acquisition; **Open settings** only after user taps (via `Geolocator.openAppSettings()`).
- **Accuracy:** `LocationAccuracy.medium` for map centering (least precise sufficient for WP1).
- **No background location**, continuous tracking, or coordinate logging in application code.

## Current location vs saved place

| Concept | WP1 behavior |
| --- | --- |
| **Current location** | `QoshniCurrentLocationSnapshot` in memory on `QoshniMapLocationController`; never written to disk or backend |
| **Default map camera** | Uzbekistan viewport; labeled “not your location” |
| **Saved place** | `QoshniSavedPlace` + `QoshniSavedPlaceRepository` interface only; no Flutter/backend persistence wired |
| **Delivery address** | `isVerifiedDeliveryAddress` is always false for snapshots |

Device coordinates do not overwrite profile or home/work addresses.

## Privacy & precision

- Coordinates are not logged by the location layer.
- No API calls send device position in WP1.
- UI copy states approximate device location is **not** a saved address.
- Static/default map camera is never exposed as GPS.

## Native configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):

- `ACCESS_COARSE_LOCATION`
- `ACCESS_FINE_LOCATION`

**iOS** (`ios/Runner/Info.plist`):

- `NSLocationWhenInUseUsageDescription` (when-in-use only)

**Dependency added:** `geolocator` (platform adapter behind `QoshniLocationProvider`).

## Known limitations

- GPS vs network source is usually reported as `fused` (OS limitation).
- Widget tests use `FakeQoshniLocationProvider`; they do **not** validate real OS permission dialogs.
- Saved places and backend address models are not integrated.
- Phase 16 backend pytest and migration `b0a1f0150001` remain outstanding (unchanged).

## Phase 17 WP2 (follow-up)

Logical next package: persisted saved places (or reuse existing address store), geocoding opt-in, backend location contracts, nearby search/radius using Phase 16 discovery — all building on `QoshniLocationProvider` and privacy rules above.
