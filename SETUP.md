# Team Setup Guide

How to get this project running on a new machine. Everything is in git **except
secrets** — those you copy locally and never commit.

## 1. Clone & install

```bash
git clone https://github.com/Pariploy66/Dormitory-system.git
cd Dormitory-system

cd nestjs-backend && npm install && cd ..
cd flutter-app && flutter pub get && cd ..
cd fastapi-integration && pip install -r requirements.txt && cd ..
```

## 2. Database — restore the shared snapshot

The latest database (schema + data + migration history) is committed at
`nestjs-backend/prisma/db-snapshot.sql`. It uses `--clean`, so restoring it
**drops the old objects and replaces them** with the current state. The file is
plain `CREATE` + `INSERT` SQL, so it runs in either pgAdmin or psql.

**Option A — pgAdmin (GUI):**
1. Right-click *Databases* → *Create* → *Database* → name it `student`.
2. Click the `student` database → open *Query Tool*.
3. Open file 📁 → select `nestjs-backend/prisma/db-snapshot.sql` → Run (F5).

**Option B — psql (command line):**
```bash
psql -U postgres -c "CREATE DATABASE student;"
psql -U postgres -d student -f nestjs-backend/prisma/db-snapshot.sql
```

> Use the restore above — do **not** run `prisma migrate deploy` on an empty DB
> (the first migration carries legacy seed data that conflicts with later
> migrations). The snapshot already includes the correct migration history, so
> `npx prisma migrate status` will report "up to date" afterwards.

## 3. Secrets (not in git)

Each service uses a single `.env` file (gitignored). Copy the template and fill
in real values:

```bash
cp nestjs-backend/.env.example       nestjs-backend/.env
cp fastapi-integration/.env.example  fastapi-integration/.env
cp flutter-app/.env.example          flutter-app/.env
```

Then set:
- `DATABASE_URL` (nestjs-backend/.env) — your local Postgres password
- `THAID_CLIENT_ID` / `THAID_CLIENT_SECRET` / `THAID_API_KEY` — ask the team (sandbox creds)
- `INTERNAL_API_KEY` — keep identical in nestjs-backend **and** fastapi-integration
- `firebase-service-account.json` — get from the team, place in `nestjs-backend/` (gitignored)

> The team lead sends the real secret values separately (chat) — they are never
> committed. Everything else you need is already in this repo.

## 4. Run

```bash
# 1) NestJS backend (reads .env automatically)
cd nestjs-backend && npm run start:dev

# 2) FastAPI integration
cd fastapi-integration && python main.py

# 3) Flutter app
cd flutter-app && flutter run --dart-define-from-file=.env
```

Open Prisma Studio to inspect the DB: `cd nestjs-backend && npm run prisma:studio`.

## Auth

Login is **ThaID only** (no username/password). On the ThaID sandbox login page,
enter a 13-digit national ID to sign in. Access is allowed only for a registered
guardian of an ACTIVE student. A parent record is created/updated on first login
(keyed by `citizen_id`).

Load the registrar registry (students + guardians) in one call:
`POST /internal/registry/sync` (header `X-Internal-API-Key`) with
`{ students: [...], guardians: [{ parentCitizenId, studentCode, relationship }] }`.
The seeded snapshot already contains mock data, so this is only needed to refresh it.
