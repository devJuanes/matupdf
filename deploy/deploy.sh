#!/usr/bin/env bash
# MatuPDF — build + subida + PM2 reload
# Uso: bash deploy/deploy.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/deploy/deploy.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Crea deploy/deploy.env desde deploy/deploy.env.example"
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

: "${DEPLOY_HOST:?DEPLOY_HOST requerido}"
: "${REMOTE_APP_DIR:?REMOTE_APP_DIR requerido}"
: "${MATUDB_URL:?MATUDB_URL requerido}"
: "${MATUDB_PROJECT_ID:?MATUDB_PROJECT_ID requerido}"
: "${MATUDB_API_KEY:?MATUDB_API_KEY requerido}"

cd "$ROOT"

echo "==> Flutter build web (release)..."
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run \
  --dart-define=MATUDB_URL="$MATUDB_URL" \
  --dart-define=MATUDB_PROJECT_ID="$MATUDB_PROJECT_ID" \
  --dart-define=MATUDB_API_KEY="$MATUDB_API_KEY"

echo "==> Parcheando bootstrap..."
node deploy/patch_web_build.js

echo "==> Subiendo build y scripts PM2..."
ssh "$DEPLOY_HOST" "mkdir -p $REMOTE_APP_DIR/build/web $REMOTE_APP_DIR/deploy"
scp -r build/web/* "${DEPLOY_HOST}:${REMOTE_APP_DIR}/build/web/"
scp deploy/server.js "${DEPLOY_HOST}:${REMOTE_APP_DIR}/deploy/server.js"
scp deploy/ecosystem.config.cjs "${DEPLOY_HOST}:${REMOTE_APP_DIR}/deploy/ecosystem.config.cjs"

echo "==> PM2 reload..."
ssh "$DEPLOY_HOST" "cd $REMOTE_APP_DIR && pm2 startOrReload deploy/ecosystem.config.cjs --update-env && pm2 save"

echo ""
echo "Deploy OK → https://matupdf.matubyte.com"
