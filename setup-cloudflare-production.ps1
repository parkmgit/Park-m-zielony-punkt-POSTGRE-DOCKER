# Park M Trees - Production Setup with Cloudflare Tunnel
# Kompletna instalacja aplikacji z domena trees.park-m.pl

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Park M Trees - Production Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Krok 1: Pobierz Cloudflared
Write-Host "[1/5] Downloading Cloudflare Tunnel..." -ForegroundColor Yellow
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -UseBasicParsing -OutFile C:\cloudflared.exe https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe

# Przenies do Program Files
Write-Host "[1/5] Installing Cloudflared..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\Program Files\Cloudflared" -Force | Out-Null
Move-Item -Path C:\cloudflared.exe -Destination "C:\Program Files\Cloudflared\cloudflared.exe" -Force

# Dodaj do PATH
$env:Path += ";C:\Program Files\Cloudflared"
[Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::Machine)

Write-Host "[1/5] Cloudflared installed!" -ForegroundColor Green
Write-Host ""

# Krok 2: Logowanie do Cloudflare
Write-Host "[2/5] Cloudflare Login" -ForegroundColor Yellow
Write-Host "Opening browser for Cloudflare authentication..." -ForegroundColor Cyan
Write-Host "Please login and select domain: park-m.pl" -ForegroundColor Cyan
Write-Host ""
& "C:\Program Files\Cloudflared\cloudflared.exe" tunnel login

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cloudflare login failed!" -ForegroundColor Red
    exit 1
}

Write-Host "[2/5] Logged in successfully!" -ForegroundColor Green
Write-Host ""

# Krok 3: Utworz tunel
Write-Host "[3/5] Creating Cloudflare Tunnel..." -ForegroundColor Yellow
& "C:\Program Files\Cloudflared\cloudflared.exe" tunnel create park-m-trees

# Znajdz ID tunelu
$tunnelFiles = Get-ChildItem -Path "$env:USERPROFILE\.cloudflared" -Filter "*.json"
if ($tunnelFiles.Count -eq 0) {
    Write-Host "ERROR: Tunnel creation failed!" -ForegroundColor Red
    exit 1
}

$tunnelId = $tunnelFiles[0].BaseName
Write-Host "Tunnel ID: $tunnelId" -ForegroundColor Cyan

# Utworz config.yml
$configContent = @"
tunnel: $tunnelId
credentials-file: $env:USERPROFILE\.cloudflared\$tunnelId.json

ingress:
  - hostname: trees.park-m.pl
    service: http://localhost:3000
  - service: http_status:404
"@

$configContent | Out-File -FilePath "$env:USERPROFILE\.cloudflared\config.yml" -Encoding utf8

Write-Host "[3/5] Tunnel created!" -ForegroundColor Green
Write-Host ""

# Krok 4: Skonfiguruj DNS
Write-Host "[4/5] Configuring DNS..." -ForegroundColor Yellow
& "C:\Program Files\Cloudflared\cloudflared.exe" tunnel route dns park-m-trees trees.park-m.pl

Write-Host "[4/5] DNS configured!" -ForegroundColor Green
Write-Host ""

# Krok 5: Zainstaluj jako usluge Windows
Write-Host "[5/5] Installing as Windows Service..." -ForegroundColor Yellow

# Cloudflared jako usluga
& "C:\Program Files\Cloudflared\cloudflared.exe" service install

# Uruchom usluge
Start-Service cloudflared
Set-Service -Name cloudflared -StartupType Automatic

Write-Host "[5/5] Cloudflare Tunnel service installed!" -ForegroundColor Green
Write-Host ""

# Krok 6: Zainstaluj aplikacje jako usluge
Write-Host "[6/6] Installing application as Windows Service..." -ForegroundColor Yellow

# Pobierz NSSM
Invoke-WebRequest -UseBasicParsing -OutFile C:\nssm.zip https://nssm.cc/release/nssm-2.24.zip
Expand-Archive -Path C:\nssm.zip -DestinationPath C:\nssm -Force

# Zainstaluj aplikacje
$nodePath = (Get-Command node).Source
$appPath = "C:\park-m-trees\.next\standalone\server.js"

C:\nssm\nssm-2.24\win64\nssm.exe install ParkMTreesApp $nodePath $appPath
C:\nssm\nssm-2.24\win64\nssm.exe set ParkMTreesApp AppDirectory "C:\park-m-trees"
C:\nssm\nssm-2.24\win64\nssm.exe set ParkMTreesApp AppEnvironmentExtra NODE_ENV=production DB_HOST=192.168.3.218 DB_PORT=5432 DB_USER=postgres DB_PASSWORD=Postgres2025 DB_NAME=park_m_trees DB_SSL=false

# Uruchom aplikacje
C:\nssm\nssm-2.24\win64\nssm.exe start ParkMTreesApp
Set-Service -Name ParkMTreesApp -StartupType Automatic

Write-Host "[6/6] Application service installed!" -ForegroundColor Green
Write-Host ""

# Podsumowanie
Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is now available at:" -ForegroundColor Cyan
Write-Host "https://trees.park-m.pl" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "Services installed:" -ForegroundColor Yellow
Write-Host "- cloudflared (Cloudflare Tunnel)" -ForegroundColor White
Write-Host "- ParkMTreesApp (Next.js Application)" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "- Check services: Get-Service cloudflared,ParkMTreesApp" -ForegroundColor White
Write-Host "- Restart app: Restart-Service ParkMTreesApp" -ForegroundColor White
Write-Host "- View logs: C:\nssm\nssm-2.24\win64\nssm.exe tail ParkMTreesApp" -ForegroundColor White
Write-Host ""
Write-Host "Note: It may take 1-2 minutes for DNS to propagate." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
