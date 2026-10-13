#!/usr/bin/env bash
# Vercel build entry: resolve dependencies and produce release web output in build/web.
# Entry target matches local dev: lib/main_development.dart
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash "$ROOT_DIR/scripts/vercel-install-flutter.sh"

FLUTTER_HOME="${FLUTTER_HOME:-$ROOT_DIR/.flutter-sdk}"
export PATH="$FLUTTER_HOME/bin:$PATH"

flutter pub get
flutter build web --release -t lib/main_development.dart

if [ ! -f "$ROOT_DIR/build/web/index.html" ]; then
  echo "Expected build output at build/web/index.html was not found." >&2
  exit 1
fi

echo "Web build complete: build/web"
