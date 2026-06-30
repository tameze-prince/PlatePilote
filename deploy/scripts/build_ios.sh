#!/usr/bin/env bash
# build_ios.sh — PlatePilote
# Archive iOS pour TestFlight (nécessite macOS + Apple Developer account)
# Usage: ./build_ios.sh [dev|staging|prod]
set -euo pipefail

cd "$(dirname "$0")/../../FrontEnd"

FLAVOR="${1:-dev}"
echo "🔨 Build iOS — flavor: $FLAVOR"

[[ "$(uname)" != "Darwin" ]] && { echo "❌ iOS build requires macOS"; exit 1; }

# Flutter build
echo "→ Flutter build ios..."
flutter build ios --release --no-codesign \
  --dart-define=PLATEPILOT_BUILD_FLAVOR="$FLAVOR"

# Xcode archive (pour TestFlight)
ARCHIVE_PATH="build/ios/PlatePilote.xcarchive"
EXPORT_OPTIONS="build/ios/ExportOptions.plist"

echo "→ Xcode archive..."
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  archive \
  -allowProvisioningUpdates

echo "→ Export IPA..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath build/ios/ \
  -exportOptionsPlist "$EXPORT_OPTIONS"

echo "✅ iOS $FLAVOR — done"
echo "  IPA: build/ios/PlatePilote.ipa"