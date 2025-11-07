# Park M Trees - Start Application Script for Windows Server
# Uruchamia aplikacje bez docker-compose

Write-Host "Starting Park M Trees application..." -ForegroundColor Green

# Zatrzymaj stare kontenery (jesli istnieja)
Write-Host "Stopping old containers..." -ForegroundColor Yellow
docker stop park-m-app 2>$null
docker rm park-m-app 2>$null
docker stop park-m-db 2>$null
docker rm park-m-db 2>$null

# UWAGA: Docker na Windows Server nie obsluguje kontenerow Linux (PostgreSQL Alpine)
# Musisz uzyc istniejacego PostgreSQL na 192.168.3.218:5432

Write-Host "Building application image..." -ForegroundColor Yellow
docker build -t park-m-trees-app .

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed!" -ForegroundColor Red
    exit 1
}

# Uruchom aplikacje z polaczeniem do istniejacego PostgreSQL
Write-Host "Starting application..." -ForegroundColor Yellow
docker run -d --name park-m-app `
    -e DATABASE_URL="postgresql://postgres:Postgres2025@192.168.3.218:5432/park_m_trees" `
    -e DB_HOST=192.168.3.218 `
    -e DB_PORT=5432 `
    -e DB_USER=postgres `
    -e DB_PASSWORD=Postgres2025 `
    -e DB_NAME=park_m_trees `
    -e DB_SSL=false `
    -e NODE_ENV=production `
    -p 3000:3000 `
    park-m-trees-app

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to start application!" -ForegroundColor Red
    exit 1
}

# Poczekaj na start
Write-Host "Waiting for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Sprawdz status
Write-Host "Container status:" -ForegroundColor Cyan
docker ps --filter "name=park-m-app"

Write-Host ""
Write-Host "Application started!" -ForegroundColor Green
Write-Host "Local access: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Network access: http://192.168.3.218:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "- View logs: docker logs park-m-app" -ForegroundColor White
Write-Host "- Stop app: .\stop-app.ps1" -ForegroundColor White
Write-Host "- Initialize database: http://localhost:3000/api/init" -ForegroundColor White
