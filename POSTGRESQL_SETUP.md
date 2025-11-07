# 🐘 PostgreSQL - Instrukcja konfiguracji

## ✅ Co zostało zmienione:

1. ✅ Zamieniono `@netlify/neon` na `pg` (node-postgres)
2. ✅ Przepisano `lib/db.ts` na standardowy PostgreSQL
3. ✅ Zaktualizowano `package.json`
4. ✅ Utworzono nowy `env.example` z konfiguracją PostgreSQL

---

## 🚀 Kroki instalacji

### 1. Zainstaluj zależności

```bash
npm install
```

To zainstaluje:
- `pg` - oficjalny klient PostgreSQL dla Node.js
- `@types/pg` - typy TypeScript dla pg

### 2. Skonfiguruj bazę danych

Utwórz plik `.env.local` w głównym katalogu projektu:

```bash
cp env.example .env.local
```

#### Opcja A: Użyj DATABASE_URL (zalecane)

Jeśli masz gotowy connection string (np. z Render, Railway, Neon, Supabase):

```env
DATABASE_URL=postgresql://user:password@host:5432/database_name
DB_SSL=true
```

#### Opcja B: Użyj osobnych zmiennych

Dla lokalnej bazy PostgreSQL:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=twoje_haslo
DB_NAME=park_m_trees
DB_SSL=false
```

### 3. Utwórz bazę danych

Jeśli używasz lokalnego PostgreSQL:

```bash
# Zaloguj się do PostgreSQL
psql -U postgres

# Utwórz bazę danych
CREATE DATABASE park_m_trees;

# Wyjdź
\q
```

### 4. Uruchom aplikację

```bash
npm run dev
```

### 5. Zainicjalizuj schemat bazy danych

Otwórz w przeglądarce:
```
http://localhost:3000/api/init
```

To utworzy wszystkie tabele i wstawi dane testowe.

---

## 🌐 Hosting - Opcje bazy danych PostgreSQL

### 1. **Neon** (Zalecane - Darmowe)
- 🌐 https://neon.tech
- ✅ Darmowy plan: 0.5 GB storage
- ✅ Serverless PostgreSQL
- ✅ Automatyczne skalowanie
- ✅ Łatwa integracja

**Jak skonfigurować:**
1. Załóż konto na neon.tech
2. Utwórz nowy projekt
3. Skopiuj `DATABASE_URL` z dashboardu
4. Dodaj do `.env.local`:
   ```env
   DATABASE_URL=postgresql://user:password@ep-xxx.region.aws.neon.tech/neondb?sslmode=require
   DB_SSL=true
   ```

### 2. **Supabase** (Darmowe)
- 🌐 https://supabase.com
- ✅ Darmowy plan: 500 MB storage
- ✅ PostgreSQL + Backend-as-a-Service
- ✅ Wbudowany panel administracyjny

**Jak skonfigurować:**
1. Załóż konto na supabase.com
2. Utwórz nowy projekt
3. Przejdź do Settings → Database
4. Skopiuj `Connection string` (URI)
5. Dodaj do `.env.local`:
   ```env
   DATABASE_URL=postgresql://postgres:password@db.xxx.supabase.co:5432/postgres
   DB_SSL=true
   ```

### 3. **Railway** (Darmowe 5$)
- 🌐 https://railway.app
- ✅ $5 miesięcznie za darmo
- ✅ Łatwe wdrożenie
- ✅ Automatyczne backupy

### 4. **Render** (Darmowe)
- 🌐 https://render.com
- ✅ Darmowy plan PostgreSQL
- ✅ 90 dni retention
- ✅ Łatwa konfiguracja

### 5. **ElephantSQL** (Darmowe)
- 🌐 https://www.elephantsql.com
- ✅ Darmowy plan: 20 MB
- ✅ Dedykowany PostgreSQL

---

## 🔧 Różnice: Neon vs Standardowy PostgreSQL

| Funkcja | @netlify/neon | pg (node-postgres) |
|---------|---------------|-------------------|
| **Import** | `import { neon } from '@netlify/neon'` | `import { Pool } from 'pg'` |
| **Konfiguracja** | Automatyczna (Netlify) | Ręczna (zmienne środowiskowe) |
| **Connection** | `sql = neon()` | `pool = new Pool({...})` |
| **Zapytania** | `await sql(query, params)` | `await pool.query(query, params)` |
| **Hosting** | Tylko Netlify | Dowolny hosting |

---

## 📊 Struktura bazy danych

Aplikacja automatycznie utworzy następujące tabele:

- **users** - Użytkownicy systemu
- **projects** - Projekty (opcjonalne)
- **sites** - Budowy/lokalizacje
- **species** - Gatunki drzew
- **trees** - Drzewa
- **tree_actions** - Akcje na drzewach (podlewanie, przycinanie, itp.)
- **photos** - Zdjęcia
- **sync_queue** - Kolejka synchronizacji (offline support)

---

## 🔐 Domyślne dane logowania

Po inicjalizacji bazy (`/api/init`), dostępni będą użytkownicy:

| Email | Hasło | Rola |
|-------|-------|------|
| admin@park-m.pl | password123 | admin |
| jan.kowalski@park-m.pl | password123 | brygadzista |
| anna.nowak@park-m.pl | password123 | pracownik |
| piotr.wisniewski@park-m.pl | password123 | pracownik |

**⚠️ WAŻNE:** Zmień hasła po pierwszym logowaniu!

---

## 🐛 Rozwiązywanie problemów

### Błąd: "password authentication failed"
- Sprawdź hasło w `.env.local`
- Upewnij się, że użytkownik PostgreSQL istnieje

### Błąd: "database does not exist"
- Utwórz bazę danych: `CREATE DATABASE park_m_trees;`

### Błąd: "connection refused"
- Sprawdź czy PostgreSQL jest uruchomiony
- Sprawdź `DB_HOST` i `DB_PORT` w `.env.local`

### Błąd: "SSL connection required"
- Ustaw `DB_SSL=true` w `.env.local`

### Błąd: "Cannot find module 'pg'"
- Uruchom: `npm install`

---

## 📱 Kompatybilność

✅ Aplikacja nadal działa jako PWA  
✅ Offline support (sync_queue)  
✅ Wszystkie funkcje zachowane  
✅ Można zainstalować na telefonie  

---

## 🎯 Następne kroki

1. ✅ Zainstaluj zależności: `npm install`
2. ✅ Skonfiguruj `.env.local`
3. ✅ Utwórz bazę danych PostgreSQL
4. ✅ Uruchom aplikację: `npm run dev`
5. ✅ Zainicjalizuj bazę: http://localhost:3000/api/init
6. ✅ Zaloguj się i testuj!

---

**Gotowe! Aplikacja teraz używa standardowego PostgreSQL! 🎉**
