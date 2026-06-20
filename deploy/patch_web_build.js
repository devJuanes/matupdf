/**
 * Parches post-build para Flutter Web en producción.
 * - CanvasKit local (sin depender de gstatic.com)
 * - Sin service worker (evita pantalla en blanco por caché corrupta)
 */
const fs = require('fs');
const path = require('path');

const webDir = path.resolve(__dirname, '../build/web');
const bootstrapPath = path.join(webDir, 'flutter_bootstrap.js');

if (!fs.existsSync(bootstrapPath)) {
  console.error('No existe build/web/flutter_bootstrap.js — corre flutter build web primero.');
  process.exit(1);
}

let content = fs.readFileSync(bootstrapPath, 'utf8');

content = content.replace(
  /_flutter\.loader\.load\(\{[\s\S]*?\}\);/,
  `_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});`,
);

fs.writeFileSync(bootstrapPath, content, 'utf8');
console.log('patch_web_build: flutter_bootstrap.js actualizado (CanvasKit local, sin SW).');
