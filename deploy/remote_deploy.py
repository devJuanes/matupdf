#!/usr/bin/env python3
"""Despliegue remoto MatuPDF vía SFTP + SSH. Uso:
   set DEPLOY_SSH_PASSWORD=tu_clave
   python deploy/remote_deploy.py
"""
from __future__ import annotations

import os
import stat
import subprocess
import sys
from pathlib import Path

import paramiko

HOST = os.environ.get("DEPLOY_HOST", "13.140.160.248")
USER = os.environ.get("DEPLOY_USER", "root")
PASSWORD = os.environ.get("DEPLOY_SSH_PASSWORD", "")
APP_DIR = os.environ.get("REMOTE_APP_DIR", "/root/apps/matupdf")
ROOT = Path(__file__).resolve().parent.parent


def run(client: paramiko.SSHClient, cmd: str) -> tuple[int, str, str]:
    print(f"\n$ {cmd}")
    _, stdout, stderr = client.exec_command(cmd, get_pty=True)
    out = stdout.read().decode("utf-8", errors="replace")
    err = stderr.read().decode("utf-8", errors="replace")
    code = stdout.channel.recv_exit_status()
    if out.strip():
        print(out.rstrip())
    if err.strip():
        print(err.rstrip(), file=sys.stderr)
    return code, out, err


def upload_dir(sftp: paramiko.SFTPClient, local: Path, remote: str) -> None:
    local = local.resolve()
    for path in local.rglob("*"):
        rel = path.relative_to(local).as_posix()
        remote_path = f"{remote}/{rel}".replace("//", "/")
        if path.is_dir():
            try:
                sftp.mkdir(remote_path)
            except OSError:
                pass
        else:
            remote_parent = os.path.dirname(remote_path)
            parts = remote_parent.split("/")
            cur = ""
            for part in parts:
                if not part:
                    continue
                cur += f"/{part}"
                try:
                    sftp.mkdir(cur)
                except OSError:
                    pass
            print(f"  upload {rel}")
            sftp.put(str(path), remote_path)


def build_locally() -> None:
    env_file = ROOT / "deploy" / "deploy.env"
    defines: list[str] = []
    if env_file.is_file():
        for line in env_file.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, val = line.split("=", 1)
            key, val = key.strip(), val.strip()
            if key == "MATUDB_URL":
                defines += ["--dart-define=MATUDB_URL=" + val]
            elif key == "MATUDB_PROJECT_ID":
                defines += ["--dart-define=MATUDB_PROJECT_ID=" + val]
            elif key == "MATUDB_API_KEY":
                defines += ["--dart-define=MATUDB_API_KEY=" + val]
            elif key == "PAYMATUBYTE_URL":
                defines += ["--dart-define=PAYMATUBYTE_URL=" + val]
            elif key == "PAYMATUBYTE_API_KEY":
                defines += ["--dart-define=PAYMATUBYTE_API_KEY=" + val]

    print("\n==> Flutter build web (release)...")
    subprocess.run(
        "flutter build web --release --no-web-resources-cdn --no-wasm-dry-run "
        + " ".join(defines),
        cwd=ROOT,
        check=True,
        shell=True,
    )
    subprocess.run("node deploy/patch_web_build.js", cwd=ROOT, check=True, shell=True)


def main() -> int:
    if not PASSWORD:
        print("Define DEPLOY_SSH_PASSWORD", file=sys.stderr)
        return 1

    try:
        build_locally()
    except subprocess.CalledProcessError as exc:
        print(f"Build falló: {exc}", file=sys.stderr)
        return exc.returncode or 1

    build_dir = ROOT / "build" / "web"

    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    print(f"Conectando a {USER}@{HOST}...")
    client.connect(HOST, username=USER, password=PASSWORD, timeout=60)

    run(client, f"mkdir -p {APP_DIR}/build/web {APP_DIR}/deploy")

    sftp = client.open_sftp()
    print("\n==> Subiendo build/web ...")
    upload_dir(sftp, build_dir, f"{APP_DIR}/build/web")

    deploy_files = [
        "server.js",
        "ecosystem.config.cjs",
        "nginx-matupdf.conf",
        "setup-server.sh",
    ]
    print("\n==> Subiendo scripts deploy ...")
    for name in deploy_files:
        local = ROOT / "deploy" / name
        remote = f"{APP_DIR}/deploy/{name}"
        print(f"  upload deploy/{name}")
        sftp.put(str(local), remote)
        if name.endswith(".sh"):
            sftp.chmod(remote, stat.S_IRWXU | stat.S_IRGRP | stat.S_IROTH)
    sftp.close()

    print("\n==> PM2 reload ...")
    run(client, f"cd {APP_DIR} && pm2 startOrReload deploy/ecosystem.config.cjs --update-env && pm2 save")

    print("\n==> Estado PM2 ...")
    run(client, "pm2 list")
    run(client, "curl -sI http://127.0.0.1:3088/ | head -5")

    client.close()
    print("\nDeploy completado -> https://matupdf.matubyte.com")
    return 0


if __name__ == "__main__":
    sys.exit(main())
