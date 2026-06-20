#!/usr/bin/env python3
"""Ejecuta setup PM2+Nginx en el servidor (archivos ya subidos)."""
import os, sys, paramiko
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')
HOST = '13.140.160.248'
USER = 'root'
PASS = os.environ.get('DEPLOY_SSH_PASSWORD', '')
APP = '/root/apps/matupdf'
ROOT = __import__('pathlib').Path(__file__).resolve().parent.parent

c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect(HOST, username=USER, password=PASS, timeout=60)
sftp = c.open_sftp()
for name in ['setup-server.sh', 'server.js', 'ecosystem.config.cjs', 'nginx-matupdf.conf']:
    local = ROOT / 'deploy' / name
    data = local.read_bytes().replace(b'\r\n', b'\n')
    remote = f'{APP}/deploy/{name}'
    with sftp.open(remote, 'wb') as f:
        f.write(data)
    if name.endswith('.sh'):
        sftp.chmod(remote, 0o755)
sftp.close()

def run(cmd):
    print('$', cmd)
    _, o, e = c.exec_command(cmd, get_pty=True)
    out = o.read().decode('utf-8', errors='replace')
    err = e.read().decode('utf-8', errors='replace')
    code = o.channel.recv_exit_status()
    if out: print(out)
    if err: print(err, file=sys.stderr)
    return code

code = run(f'cd {APP} && bash deploy/setup-server.sh')
run('pm2 list')
run('curl -sI http://127.0.0.1:3088/ | head -8')
run('curl -sI -H "Host: matupdf.matubyte.com" http://127.0.0.1/ | head -8')
c.close()
sys.exit(code)
