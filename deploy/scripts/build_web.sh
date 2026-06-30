#!/usr/bin/env bash
# build_web.sh — PlatePilote
# Build web release + déploiement Vercel/Netlify préparé
# Usage: ./build_web.sh
set -euo pipefail

cd "$(dirname "$0")/../../FrontEnd"

echo "🔨 Build Web — release"

flutter build web --release \
  --dart-define=PLATEPILOT_BUILD_FLAVOR=prod \
  --base-href /

echo "✅ Web — done"
echo "  build/web/"
echo ""
echo "📦 Pour déployer :"
echo "  Vercel : cd build/web && vercel --prod"
echo "  Netlify: npx netlify deploy --prod --dir=build/web"