#!/usr/bin/env bash
# PlatePilote Android build helper.
# Usage:
#   PLATEPILOT_API_BASE_URL=http://10.0.2.2:8081/api/v1 ./build_android.sh dev
#   PLATEPILOT_API_BASE_URL=https://api.example.com/api/v1 ./build_android.sh prod
set -euo pipefail

cd "$(dirname "$0")/../../FrontEnd"

FLAVOR="${1:-dev}"
API_BASE_URL="${PLATEPILOT_API_BASE_URL:-}"

if [[ -z "$API_BASE_URL" ]]; then
  echo "ERROR: Set PLATEPILOT_API_BASE_URL to the API URL for this build." >&2
  exit 1
fi

if [[ "$FLAVOR" == "prod" ]]; then
  if [[ "$API_BASE_URL" != https://* ]]; then
    echo "ERROR: Production builds require an HTTPS API URL." >&2
    exit 1
  fi
  if [[ ! -f android/key.properties ]]; then
    echo "ERROR: android/key.properties is required for a production release." >&2
    exit 1
  fi
  echo "Building signed production APKs..."
  flutter build apk --release --split-per-abi \
    --dart-define=PLATEPILOT_API_BASE_URL="$API_BASE_URL" \
    --dart-define=PLATEPILOT_BUILD_FLAVOR="$FLAVOR"
  echo "Building signed production Android App Bundle..."
  flutter build appbundle --release \
    --dart-define=PLATEPILOT_API_BASE_URL="$API_BASE_URL" \
    --dart-define=PLATEPILOT_BUILD_FLAVOR="$FLAVOR"
else
  echo "Building debug APK..."
  flutter build apk --debug \
    --dart-define=PLATEPILOT_API_BASE_URL="$API_BASE_URL" \
    --dart-define=PLATEPILOT_BUILD_FLAVOR="$FLAVOR"
fi

echo "Android build completed: $FLAVOR"
if [[ "$FLAVOR" == "prod" ]]; then
  echo "APKs: build/app/outputs/flutter-apk/"
  echo "AAB:  build/app/outputs/bundle/release/app-release.aab"
else
  echo "APK: build/app/outputs/flutter-apk/app-debug.apk"
fi
