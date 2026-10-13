#!/usr/bin/env bash
# Installs a pinned Flutter SDK for Vercel Linux builders (Flutter is not preinstalled).
# Override FLUTTER_VERSION to match your local SDK; default matches Dart ^3.13.1 / stable 3.47.1.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.1}"
FLUTTER_HOME="${FLUTTER_HOME:-$ROOT_DIR/.flutter-sdk}"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "Cloning Flutter $FLUTTER_VERSION into $FLUTTER_HOME ..."
  rm -rf "$FLUTTER_HOME"
  git clone https://github.com/flutter/flutter.git \
    --branch "$FLUTTER_VERSION" \
    --depth 1 \
    "$FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --enable-web --no-analytics
flutter --version
# Pre-download web tooling so the build step is less likely to time out.
flutter precache --web --no-android --no-ios --no-linux --no-macos --no-windows --no-fuchsia

echo "Flutter SDK ready at $FLUTTER_HOME"
