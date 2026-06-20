/** PM2 — MatuPDF Flutter Web */
module.exports = {
  apps: [
    {
      name: 'matupdf',
      cwd: '/root/apps/matupdf',
      script: 'deploy/server.js',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        HOST: '127.0.0.1',
        PORT: 3088,
      },
    },
  ],
};
