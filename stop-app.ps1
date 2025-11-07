# Park M Trees - Stop Application Script

Write-Host "🛑 Stopping Park M Trees application..." -ForegroundColor Yellow

# Zatrzymaj kontenery
docker stop park-m-app park-m-db -ErrorAction SilentlyContinue

# Usuń kontenery
docker rm park-m-app park-m-db -ErrorAction SilentlyContinue

# Opcjonalnie: usuń obrazy
# docker rmi park-m-trees-app -ErrorAction SilentlyContinue

Write-Host "✅ Application stopped!" -ForegroundColor Green
Write-Host "📊 Container status:" -ForegroundColor Cyan
docker ps --filter "name=park-m-"
