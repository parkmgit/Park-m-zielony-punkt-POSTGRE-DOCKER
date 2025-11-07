# 🐳 Park M Trees - Docker Deployment

## 🌐 Działająca aplikacja: https://trees.park-m.pl/

Kompletna konfiguracja Docker z darmowym SSL (Let's Encrypt) dla domeny `trees.park-m.pl`.

---

## 📋 Wymagania

- Serwer z Docker i Docker Compose
- Domena `trees.park-m.pl` skierowana na IP serwera
- Porty 80 i 443 dostępne na serwerze

---

## 🚀 Szybki start (produkcja)

### 1. Przygotuj serwer

```bash
# Zainstaluj Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Zainstaluj Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Skopiuj pliki na serwer

```bash
# Użyj Git lub scp/sftp
git clone <twoje-repo> park-m-trees
cd park-m-trees
```

### 3. Skonfiguruj SSL

```bash
# Uprawieńienia do skryptu
chmod +x setup-ssl.sh

# Uruchom skrypt (zmień email na swój)
./setup-ssl.sh
```

### 4. Uruchom aplikację

```bash
# Zbuduj i uruchom wszystkie kontenery
docker-compose up -d

# Sprawdź status
docker-compose ps
```

### 5. Zainicjalizuj bazę danych

```bash
# Otwórz w przeglądarce
https://trees.park-m.pl/api/init
```

---

## 📁 Struktura plików

```
├── Dockerfile                 # Konfiguracja kontenera aplikacji
├── docker-compose.yml         # Konfiguracja wszystkich usług
├── nginx/
│   ├── nginx.conf            # Główna konfiguracja Nginx
│   └── conf.d/
│       └── trees.park-m.pl.conf  # Konfiguracja domeny z SSL
├── setup-ssl.sh              # Skrypt do generowania SSL
├── init-db.sql               # Dane startowe bazy
└── .dockerignore             # Pliki ignorowane w Docker
```

---

## 🔧 Konfiguracja

### Baza danych
- **Host:** db (wewnętrzny)
- **Port:** 5432
- **User:** postgres
- **Password:** Postgres2025
- **Database:** park_m_trees

### SSL Certyfikaty
- **Lokalizacja:** `./letsencrypt/`
- **Automatyczne odnawianie:** Tak (Let's Encrypt)
- **Ważność:** 90 dni

### Kontenery
- **app:** Next.js aplikacja (port 3000)
- **db:** PostgreSQL (port 5432, wewnętrzny)
- **nginx:** Reverse proxy (porty 80, 443)

---

## 🔄 Zarządzanie

### Uruchomienie
```bash
docker-compose up -d
```

### Zatrzymanie
```bash
docker-compose down
```

### Logi
```bash
# Wszystkie logi
docker-compose logs

# Logi konkretnej usługi
docker-compose logs app
docker-compose logs nginx
docker-compose logs db
```

### Aktualizacja
```bash
# Zbuduj na nowo i uruchom
docker-compose up -d --build
```

### Backup bazy danych
```bash
# Export bazy
docker-compose exec db pg_dump -U postgres park_m_trees > backup.sql

# Import bazy
docker-compose exec -T db psql -U postgres park_m_trees < backup.sql
```

---

## 🔒 Bezpieczeństwo

- ✅ HTTPS z Let's Encrypt
- ✅ Automatyczne przekierowanie HTTP → HTTPS
- ✅ Security headers w Nginx
- ✅ Baza danych tylko w sieci wewnętrznej
- ✅ Brak otwartych portów poza 80/443

---

## 🐛 Rozwiązywanie problemów

### SSL nie działa
```bash
# Sprawdź status certyfikatu
docker-compose exec nginx ls -la /etc/letsencrypt/live/trees.park-m.pl/

# Odnow certyfikat
./setup-ssl.sh
```

### Aplikacja nie startuje
```bash
# Sprawdź logi
docker-compose logs app

# Zrestartuj
docker-compose restart app
```

### Baza danych nie działa
```bash
# Sprawdź logi PostgreSQL
docker-compose logs db

# Połącz się z bazą
docker-compose exec db psql -U postgres -d park_m_trees
```

---

## 📱 PWA Funkcje

Aplikacja działa jako Progressive Web App:
- ✅ Instalacja na telefonie
- ✅ Offline cache
- ✅ Service Worker
- ✅ Push notifications (przygotowane)

---

## 💰 Koszty

### **Docker:** Darmowy
### **Let's Encrypt SSL:** Darmowy  
### **Serwer:**
- VPS: $5-10/miesiąc
- Własny serwer: $0

---

## 🎯 Domyślne dane logowania

| Email | Hasło | Rola |
|-------|-------|------|
| admin@park-m.pl | password123 | admin |
| jan.kowalski@park-m.pl | password123 | brygadzista |
| anna.nowak@park-m.pl | password123 | pracownik |
| piotr.wisniewski@park-m.pl | password123 | pracownik |

**⚠️ Zmień hasła po pierwszym logowaniu!**

---

## 🚀 Gotowe!

Aplikacja działa na: **https://trees.park-m.pl** 🎉

Wszystkie komponenty są w kontenerach Docker, SSL jest automatyczne, a baza danych bezpieczna.
