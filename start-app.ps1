# Park M Trees - Start Application Script
# Uruchamia aplikację bez docker-compose

Write-Host "🚀 Starting Park M Trees application..." -ForegroundColor Green

# Zatrzymaj stare kontenery (jeśli istnieją)
Write-Host "🛑 Stopping old containers..." -ForegroundColor Yellow
docker stop park-m-app park-m-db -ErrorAction SilentlyContinue
docker rm park-m-app park-m-db -ErrorAction SilentlyContinue

# Zbuduj obraz aplikacji
Write-Host "🔨 Building application image..." -ForegroundColor Yellow
docker build -t park-m-trees-app .

# Uruchom bazę danych PostgreSQL
Write-Host "🗄️ Starting PostgreSQL database..." -ForegroundColor Yellow
docker run -d --name park-m-db `
    -e POSTGRES_DB=park_m_trees `
    -e POSTOSA_USER=postgres `
    -e POSTOSA_PASSWORD=Postgres2025 `
    -p 5432:5432 `
    postgres:15-alpine

# Poczekaj na start bazy danych
Write-Host "⏳ Waiting for database to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Uruchom aplikację
Write-Host "🌱 Starting application..." -ForegroundColor Yellow
docker run -d --name park-m-app `
    -e DATABASE_URL="postgresql://postgres:Postgres2025@localhost:5432/park_m_trees" `
    -e DB_HOST=localhost `
    -e DB_PORT=5432 `
    -e DB_USER=postgres `
    -e DB_PASSWORD=Postgres2025 `
    -e DB_NAME=park_m_trees `
    -e DB_SSL=false `
    -e NODE_ENV=production `
    -p 3000:3000 `
    park-m-trees-app

# Sprawdź status
Write-Host "📊 Container status:" -ForegroundColor Cyan
docker ps --filter "name=park-m-"

Write-Host ""
Write-Host "✅ Application started!" -ForegroundColor Green
Write-Host "🌐 Local access: http://localhost:3000" -ForegroundColor Cyan
Write-Host "🌐 Network access: http://[IP-serwera]:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 Useful commands:" -ForegroundColor Yellow
Write-Host "- View logs: docker logs park-m-app" -ForegroundColor White
Write-Host "- Stop app: ./stop-app.ps1" -ForegroundColor White
Write-Host "- Initialize database: http://localhost:3000/api/init" -ForegroundColor White
