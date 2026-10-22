#!/usr/bin/env bash
# Vercel build entry: resolve dependencies and produce release web output in build/web.
# Entry target matches local dev: lib/main_development.dart
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash "$ROOT_DIR/scripts/vercel-install-flutter.sh"

FLUTTER_HOME="${FLUTTER_HOME:-$ROOT_DIR/.flutter-sdk}"
export PATH="$FLUTTER_HOME/bin:$PATH"

# Public feature flags (not security). Preview keeps dev defaults (samples on).
# Production Vercel deploys disable Business Center samples unless overridden.
DART_DEFINES=()
if [ "${VERCEL_ENV:-}" = "production" ]; then
  DART_DEFINES+=(
    "--dart-define=ENABLE_BUSINESS_PROFILE_SAMPLES=false"
    "--dart-define=ENABLE_BUSINESS_OFFERING_SAMPLES=false"
  )
fi
if [ -n "${ENABLE_BUSINESS_PROFILE_SAMPLES:-}" ]; then
  DART_DEFINES+=(
    "--dart-define=ENABLE_BUSINESS_PROFILE_SAMPLES=${ENABLE_BUSINESS_PROFILE_SAMPLES}"
  )
fi
if [ -n "${ENABLE_BUSINESS_OFFERING_SAMPLES:-}" ]; then
  DART_DEFINES+=(
    "--dart-define=ENABLE_BUSINESS_OFFERING_SAMPLES=${ENABLE_BUSINESS_OFFERING_SAMPLES}"
  )
fi
if [ -n "${QOSHNI_API_BASE_URL:-}" ]; then
  DART_DEFINES+=(
    "--dart-define=QOSHNI_API_BASE_URL=${QOSHNI_API_BASE_URL}"
  )
fi
if [ -n "${MAPBOX_ACCESS_TOKEN:-}" ]; then
  DART_DEFINES+=(
    "--dart-define=MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}"
  )
fi

flutter pub get
flutter build web --release -t lib/main_development.dart "${DART_DEFINES[@]}"

if [ ! -f "$ROOT_DIR/build/web/index.html" ]; then
  echo "Expected build output at build/web/index.html was not found." >&2
  exit 1
fi

echo "Web build complete: build/web"
