/**
 * Servidor estático para Flutter Web (SPA).
 * PM2 lo ejecuta; Nginx hace proxy a este puerto.
 */
const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '../build/web');
const PORT = Number(process.env.PORT || 3088);
const HOST = process.env.HOST || '127.0.0.1';

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.map': 'application/json',
};

function sendFile(res, filePath, statusCode = 200) {
  const ext = path.extname(filePath).toLowerCase();
  const stream = fs.createReadStream(filePath);
  stream.on('error', () => {
    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Not found');
  });
  res.writeHead(statusCode, {
    'Content-Type': MIME[ext] || 'application/octet-stream',
    ...(ext === '.html'
        ? { 'Cache-Control': 'no-store, no-cache, must-revalidate' }
        : {}),
  });
  stream.pipe(res);
}

const server = http.createServer((req, res) => {
  const urlPath = decodeURIComponent((req.url || '/').split('?')[0]);
  let filePath = path.join(ROOT, urlPath === '/' ? 'index.html' : urlPath);

  if (!filePath.startsWith(ROOT)) {
    res.writeHead(403);
    return res.end('Forbidden');
  }

  fs.stat(filePath, (err, stat) => {
    if (!err && stat.isDirectory()) {
      filePath = path.join(filePath, 'index.html');
    }

    fs.stat(filePath, (err2, stat2) => {
      if (err2 || !stat2.isFile()) {
        return sendFile(res, path.join(ROOT, 'index.html'));
      }
      sendFile(res, filePath);
    });
  });
});

server.listen(PORT, HOST, () => {
  console.log(`MatuPDF static server → http://${HOST}:${PORT} (root: ${ROOT})`);
});
