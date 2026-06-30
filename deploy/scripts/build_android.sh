#!/usr/bin/env bash
# build_android.sh — PlatePilote
# Génère APK debug + AAB release dans build/app/outputs/
# Usage: ./build_android.sh [dev|staging|prod]
set -euo pipefail

cd "$(dirname "$0")/../../FrontEnd"

FLAVOR="${1:-dev}"
echo "🔨 Build Android — flavor: $FLAVOR"

# Debug APK (rapide, tous les jours)
echo "→ APK debug..."
flutter build apk --debug --dart-define=PLATEPILOT_BUILD_FLAVOR="$FLAVOR"

# Release AAB (signé, pour App Distribution / Play Store)
if [[ "$FLAVOR" == "prod" ]]; then
  echo "→ AAB release (signé)..."
  flutter build appbundle --release \
    --dart-define=PLATEPILOT_BUILD_FLAVOR="$FLAVOR"
fi

echo "✅ Android $FLAVOR — done"
echo "  APK: build/app/outputs/flutter-apk/app-debug.apk"
echo "  AAB: build/app/outputs/bundle/release/app-release.aab"