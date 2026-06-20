# MatuPDF — build + subida + PM2 reload
# Uso (PowerShell): .\deploy\deploy.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root "deploy\deploy.env"

if (-not (Test-Path $EnvFile)) {
    Write-Host "Crea deploy\deploy.env desde deploy\deploy.env.example" -ForegroundColor Red
    exit 1
}

Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^\s*([^#=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), "Process")
    }
}

$Host_ = $env:DEPLOY_HOST
$AppDir = $env:REMOTE_APP_DIR
$MatuUrl = $env:MATUDB_URL
$MatuProject = $env:MATUDB_PROJECT_ID
$MatuKey = $env:MATUDB_API_KEY

if (-not $Host_ -or -not $AppDir) {
    Write-Host "DEPLOY_HOST y REMOTE_APP_DIR son obligatorios" -ForegroundColor Red
    exit 1
}

Set-Location $Root

Write-Host "==> Flutter build web (release)..." -ForegroundColor Cyan
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run `
    --dart-define=MATUDB_URL=$MatuUrl `
    --dart-define=MATUDB_PROJECT_ID=$MatuProject `
    --dart-define=MATUDB_API_KEY=$MatuKey

Write-Host "==> Parcheando bootstrap..." -ForegroundColor Cyan
node deploy/patch_web_build.js

$BuildDir = Join-Path $Root "build\web"
if (-not (Test-Path $BuildDir)) {
    Write-Host "No se encontró build\web" -ForegroundColor Red
    exit 1
}

Write-Host "==> Subiendo build y scripts PM2..." -ForegroundColor Cyan
ssh $Host_ "mkdir -p $AppDir/build/web $AppDir/deploy"
scp -r "$BuildDir\*" "${Host_}:${AppDir}/build/web/"
scp "$Root\deploy\server.js" "${Host_}:${AppDir}/deploy/server.js"
scp "$Root\deploy\ecosystem.config.cjs" "${Host_}:${AppDir}/deploy/ecosystem.config.cjs"

Write-Host "==> PM2 reload..." -ForegroundColor Cyan
ssh $Host_ "cd $AppDir && pm2 startOrReload deploy/ecosystem.config.cjs --update-env && pm2 save"

Write-Host ""
Write-Host "Deploy OK → https://matupdf.matubyte.com" -ForegroundColor Green
