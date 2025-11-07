# Park M Trees - Manual Cloudflare Setup (bez przegladarki)
# Uzyj tego skryptu gdy nie masz dostepu do przegladarki na serwerze

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Park M Trees - Manual Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Sprawdz czy pliki credentials istnieja
$cloudflaredDir = "$env:USERPROFILE\.cloudflared"
$certFile = "$cloudflaredDir\cert.pem"

if (-not (Test-Path $cloudflaredDir)) {
    Write-Host "Creating .cloudflared directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $cloudflaredDir -Force | Out-Null
}

if (-not (Test-Path $certFile)) {
    Write-Host ""
    Write-Host "ERROR: Missing Cloudflare credentials!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please follow these steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. On your LOCAL computer (with browser):" -ForegroundColor Cyan
    Write-Host "   - Download: https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -ForegroundColor White
    Write-Host "   - Run: cloudflared.exe tunnel login" -ForegroundColor White
    Write-Host "   - Run: cloudflared.exe tunnel create park-m-trees" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Copy these files to server:" -ForegroundColor Cyan
    Write-Host "   - C:\Users\<user>\.cloudflared\cert.pem" -ForegroundColor White
    Write-Host "   - C:\Users\<user>\.cloudflared\<TUNNEL-ID>.json" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Place them in: $cloudflaredDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "4. Run this script again" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Znajdz plik credentials tunelu
$tunnelFiles = Get-ChildItem -Path $cloudflaredDir -Filter "*.json" -ErrorAction SilentlyContinue
if ($tunnelFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "ERROR: Missing tunnel credentials file!" -ForegroundColor Red
    Write-Host "Please copy <TUNNEL-ID>.json to: $cloudflaredDir" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

$tunnelId = $tunnelFiles[0].BaseName
$tunnelFile = $tunnelFiles[0].FullName

Write-Host "Found tunnel: $tunnelId" -ForegroundColor Green
Write-Host ""

# Krok 1: Zainstaluj Cloudflared
Write-Host "[1/4] Installing Cloudflared..." -ForegroundColor Yellow
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -UseBasicParsing -OutFile C:\cloudflared.exe https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe

New-Item -ItemType Directory -Path "C:\Program Files\Cloudflared" -Force | Out-Null
Move-Item -Path C:\cloudflared.exe -Destination "C:\Program Files\Cloudflared\cloudflared.exe" -Force

$env:Path += ";C:\Program Files\Cloudflared"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::Machine)

Write-Host "[1/4] Cloudflared installed!" -ForegroundColor Green
Write-Host ""

# Krok 2: Utworz config.yml
Write-Host "[2/4] Creating configuration..." -ForegroundColor Yellow

$configContent = @"
tunnel: $tunnelId
credentials-file: $tunnelFile

ingress:
  - hostname: trees.park-m.pl
    service: http://localhost:3000
  - service: http_status:404
"@

$configContent | Out-File -FilePath "$cloudflaredDir\config.yml" -Encoding utf8

Write-Host "[2/4] Configuration created!" -ForegroundColor Green
Write-Host ""

# Krok 3: Skonfiguruj DNS (manual)
Write-Host "[3/4] DNS Configuration" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANT: You need to configure DNS manually!" -ForegroundColor Red
Write-Host ""
Write-Host "Go to Cloudflare Dashboard and add:" -ForegroundColor Cyan
Write-Host "  Type: CNAME" -ForegroundColor White
Write-Host "  Name: trees" -ForegroundColor White
Write-Host "  Target: $tunnelId.cfargotunnel.com" -ForegroundColor White
Write-Host "  Proxy: ON (orange cloud)" -ForegroundColor White
Write-Host ""
Write-Host "OR run this command on your LOCAL computer:" -ForegroundColor Cyan
Write-Host "  cloudflared.exe tunnel route dns park-m-trees trees.park-m.pl" -ForegroundColor White
Write-Host ""
$response = Read-Host "Press ENTER when DNS is configured"

Write-Host "[3/4] DNS should be configured!" -ForegroundColor Green
Write-Host ""

# Krok 4: Zainstaluj jako usluge
Write-Host "[4/4] Installing services..." -ForegroundColor Yellow

# Cloudflared jako usluga
& "C:\Program Files\Cloudflared\cloudflared.exe" service install
Start-Service cloudflared -ErrorAction SilentlyContinue
Set-Service -Name cloudflared -StartupType Automatic

# Pobierz NSSM
Invoke-WebRequest -UseBasicParsing -OutFile C:\nssm.zip https://nssm.cc/release/nssm-2.24.zip
Expand-Archive -Path C:\nssm.zip -DestinationPath C:\nssm -Force

# Zainstaluj aplikacje
$nodePath = (Get-Command node).Source
$appPath = "C:\park-m-trees\.next\standalone\server.js"

C:\nssm\nssm-2.24\win64\nssm.exe install ParkMTreesApp $nodePath $appPath
C:\nssm\nssm-2.24\win64\nssm.exe set ParkMTreesApp AppDirectory "C:\park-m-trees"
C:\nssm\nssm-2.24\win64\nssm.exe set ParkMTreesApp AppEnvironmentExtra NODE_ENV=production DB_HOST=192.168.3.218 DB_PORT=5432 DB_USER=postgres DB_PASSWORD=Postgres2025 DB_NAME=park_m_trees DB_SSL=false

C:\nssm\nssm-2.24\win64\nssm.exe start ParkMTreesApp
Set-Service -Name ParkMTreesApp -StartupType Automatic

Write-Host "[4/4] Services installed!" -ForegroundColor Green
Write-Host ""

# Podsumowanie
Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application should be available at:" -ForegroundColor Cyan
Write-Host "https://trees.park-m.pl" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "Note: DNS propagation may take 1-5 minutes." -ForegroundColor Yellow
Write-Host ""
Write-Host "Services:" -ForegroundColor Yellow
Write-Host "- cloudflared: " -NoNewline -ForegroundColor White
Get-Service cloudflared | Select-Object -ExpandProperty Status
Write-Host "- ParkMTreesApp: " -NoNewline -ForegroundColor White
Get-Service ParkMTreesApp | Select-Object -ExpandProperty Status
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
