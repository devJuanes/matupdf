#!/usr/bin/env bash
# Setup inicial en el servidor (PM2 + Nginx + SSL)
# Uso: cd ~/apps/matupdf && bash deploy/setup-server.sh
set -euo pipefail

DOMAIN="${DOMAIN:-matupdf.matubyte.com}"
APP_DIR="${APP_DIR:-/root/apps/matupdf}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Verificando Node.js y PM2"
if ! command -v node >/dev/null 2>&1; then
  echo "Instala Node.js 18+ primero (ej: curl -fsSL https://deb.nodesource.com/setup_20.x | bash -)"
  exit 1
fi

if ! command -v pm2 >/dev/null 2>&1; then
  echo "Instalando PM2 global..."
  npm install -g pm2
fi

mkdir -p "$APP_DIR/build/web"

echo "==> Nginx"
if [ -d /etc/nginx/sites-available ]; then
  cp "$SCRIPT_DIR/nginx-matupdf.conf" "/etc/nginx/sites-available/matupdf"
  ln -sf "/etc/nginx/sites-available/matupdf" "/etc/nginx/sites-enabled/matupdf"
else
  cp "$SCRIPT_DIR/nginx-matupdf.conf" "/etc/nginx/conf.d/matupdf.conf"
fi

nginx -t
systemctl reload nginx

echo "==> PM2"
cd "$APP_DIR"
pm2 startOrReload "$SCRIPT_DIR/ecosystem.config.cjs" --update-env
pm2 save
pm2 startup systemd -u root --hp /root 2>/dev/null || true

echo "==> SSL (Certbot)"
if command -v certbot >/dev/null 2>&1; then
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m contacto@matubyte.com || true
  systemctl reload nginx
else
  echo "    Certbot no instalado — configura HTTPS manualmente."
fi

echo ""
echo "Listo: PM2 (matupdf :3088) + Nginx → https://${DOMAIN}"
echo "Sube build/web con: bash deploy/deploy.sh (desde tu PC)"
