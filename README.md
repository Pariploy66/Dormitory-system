# Student Access Control System

ระบบติดตามการเข้า-ออกหอพักนักศึกษาแบบ Real-time สำหรับผู้ปกครอง

---

## Architecture Overview

```
Flutter App  ──REST/JWT──►  NestJS (Port 3000)  ──Prisma──►  PostgreSQL 16
                                  ▲  ▲
                     Internal API  │  │ FCM dispatch
                                  │  ▼
                FastAPI (Port 8000)  Firebase Cloud Messaging
                       │
              Tenacity retry + Dedup
                       │
              External Access Control API
```

---

## Directory Structure

```
student-access/
├── nestjs-backend/
│   ├── prisma/
│   │   └── schema.prisma           ← DB schema + migrations
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── common/
│   │   │   ├── prisma.service.ts
│   │   │   ├── prisma.module.ts
│   │   │   └── internal-api-key.guard.ts
│   │   ├── auth/
│   │   │   ├── auth.dto.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.module.ts
│   │   │   └── jwt.strategy.ts
│   │   ├── students/
│   │   │   └── students.module.ts  ← upsert + link endpoints
│   │   ├── access-logs/
│   │   │   ├── access-logs.service.ts
│   │   │   ├── access-logs.controller.ts
│   │   │   └── access-logs.module.ts
│   │   └── notifications/
│   │       ├── notifications.service.ts
│   │       └── notifications.module.ts
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
│
├── fastapi-integration/
│   ├── app/
│   │   ├── main.py                 ← FastAPI app + lifespan
│   │   ├── config.py               ← Pydantic settings
│   │   ├── models/
│   │   │   └── schemas.py          ← Pydantic v2 models
│   │   └── services/
│   │       ├── state.py            ← Watermark / deduplication state
│   │       ├── external_client.py  ← Tenacity retry client
│   │       ├── nestjs_client.py    ← Internal API forwarder
│   │       └── poller.py           ← Core poll loop
│   ├── main.py                     ← uvicorn entrypoint
│   ├── requirements.txt
│   └── .env.example
│
└── flutter-app/
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── constants.dart
    │   │   ├── dio_client.dart     ← Dio + JWT interceptor
    │   │   └── router.dart         ← GoRouter + auth redirect
    │   ├── data/
    │   │   ├── models.dart         ← Student, AccessLog
    │   │   └── api_repository.dart ← All API calls
    │   ├── providers/
    │   │   └── app_providers.dart  ← Riverpod providers
    │   ├── services/
    │   │   └── fcm_service.dart    ← Firebase push notifications
    │   └── ui/screens/
    │       ├── login_screen.dart
    │       ├── register_screen.dart
    │       ├── home_screen.dart    ← Student list
    │       └── logs_screen.dart    ← Access log timeline
    ├── pubspec.yaml
    └── .env.example
```

---

## Step 1 — Database Setup

### Prerequisites
- PostgreSQL 16+ running locally or via Docker

```bash
# Quick start with Docker
docker run -d \
  --name student-access-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=student_access \
  -p 5432:5432 \
  postgres:16-alpine
```

### Run Prisma Migration

```bash
cd nestjs-backend
cp .env.example .env          # edit DATABASE_URL if needed
npm install
npx prisma generate
npx prisma migrate dev --name init
```

The migration creates these tables:
- `parents` — parent accounts with ThaID/OIDC fields reserved
- `students` — student records keyed by external_student_id
- `parent_student_mapping` — many-to-many link
- `access_logs` — events with composite unique index for dedup
- `devices` — FCM tokens per parent

---

## Step 2 — NestJS Backend

```bash
cd nestjs-backend
cp .env.example .env
# Edit: JWT_SECRET, INTERNAL_API_KEY, FIREBASE_SERVICE_ACCOUNT_PATH

npm run start:dev
# Listens on http://localhost:3000
```

### Key Environment Variables

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_SECRET` | Long random secret for signing JWTs |
| `INTERNAL_API_KEY` | Shared key with FastAPI (must match) |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | Path to Firebase serviceAccountKey.json |

### API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | Public | Register parent account |
| POST | `/auth/login` | Public | Login, returns JWT |
| POST | `/auth/device` | JWT | Register FCM token |
| GET | `/me/students` | JWT | List my students |
| GET | `/me/students/:id/logs` | JWT | Access logs (parent's students only) |
| POST | `/internal/access-logs` | X-Internal-API-Key | Ingest event from FastAPI |
| POST | `/internal/students/upsert` | X-Internal-API-Key | Sync student record |
| POST | `/internal/students/link` | X-Internal-API-Key | Link parent ↔ student |

### Security Model
- JWT guards protect all parent-facing endpoints
- `getLogsForStudent` verifies `parent_student_mapping` before returning data — a parent cannot access another parent's child's records even with a valid JWT
- Internal endpoints are protected by `X-Internal-API-Key` header (not JWT)

---

## Step 3 — FastAPI Integration Layer

```bash
cd fastapi-integration
cp .env.example .env
# Edit: EXTERNAL_API_BASE_URL, EXTERNAL_API_KEY, INTERNAL_API_KEY

python -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -r requirements.txt

python main.py
# Listens on http://localhost:8000
```

### Key Environment Variables

| Variable | Description |
|---|---|
| `EXTERNAL_API_BASE_URL` | Base URL of the access control system API |
| `EXTERNAL_API_KEY` | Auth token for the external API |
| `NESTJS_BASE_URL` | http://localhost:3000 (or internal Docker hostname) |
| `INTERNAL_API_KEY` | Must match NestJS `INTERNAL_API_KEY` |
| `POLL_INTERVAL_SECONDS` | How often to poll (default: 30) |

### How Deduplication Works

1. **Watermark** — `poller_state.last_processed` is a timestamp advanced after each successful batch. Every poll only requests events newer than this timestamp.
2. **Prisma upsert** — NestJS uses `prisma.accessLog.upsert` with the composite unique key `(student_id, access_time, type)`. A re-sent event silently no-ops instead of inserting a duplicate row.

### Resilience
- Tenacity retries the external API up to 5 times with exponential back-off (2s → 30s max)
- If the external API is down, NestJS continues to serve parents normally from existing data
- Watermark is not advanced on failure, so the next poll will retry the same window

### Status Endpoints

```
GET /health       → {"status": "ok"}
GET /status       → watermark, poll interval, URLs
POST /poll/trigger → manually trigger one poll cycle
```

---

## Step 4 — Flutter App

### Prerequisites
- Flutter 3.22+ with Dart 3
- Firebase project with FCM enabled
- `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) placed in the correct platform directories

```bash
cd flutter-app
flutter pub get

# Run (replace URL for physical device)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000   # Android emulator
flutter run --dart-define=API_BASE_URL=http://localhost:3000   # iOS simulator
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:3000 # Physical device
```

### Flutter Architecture

```
main.dart
  └─ ProviderScope (Riverpod)
       └─ MaterialApp.router (GoRouter)
            ├─ /login        → LoginScreen
            ├─ /register     → RegisterScreen
            └─ /home         → HomeScreen (student list)
                 └─ /home/logs/:id → LogsScreen (access log timeline)
```

- **Riverpod** handles all state: auth status, student list, access logs
- **GoRouter** redirects to `/login` when JWT is missing, to `/home` when already authenticated
- **Dio interceptor** auto-attaches JWT to every request; on 401 it clears the token and GoRouter redirects to login
- **FCM** registers the device token on init, shows local notifications for both foreground and background messages

---

## ThaID / OIDC Future Integration

The database schema already reserves:
- `parents.thaid_sub` — the `sub` claim from ThaID's OIDC token (unique)
- `parents.identity_provider` — enum `LOCAL | THAID`

To add ThaID login in the future:
1. Add a NestJS `OidcStrategy` (passport-openidconnect) pointing to ThaID's discovery endpoint
2. On callback: upsert parent by `thaid_sub`, set `identity_provider = THAID`
3. Issue your own JWT as normal — the rest of the system is unchanged

---

## Docker Compose (optional, full-stack)

```yaml
version: '3.9'
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: student_access
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports: ["5432:5432"]
    volumes: [pgdata:/var/lib/postgresql/data]

  nestjs:
    build: ./nestjs-backend
    ports: ["3000:3000"]
    environment:
      DATABASE_URL: postgresql://postgres:password@postgres:5432/student_access
      JWT_SECRET: change-me
      INTERNAL_API_KEY: change-me-internal
    depends_on: [postgres]

  fastapi:
    build: ./fastapi-integration
    ports: ["8000:8000"]
    environment:
      NESTJS_BASE_URL: http://nestjs:3000
      INTERNAL_API_KEY: change-me-internal
      EXTERNAL_API_BASE_URL: https://access-control.example.com/api
      EXTERNAL_API_KEY: your-key
    depends_on: [nestjs]

volumes:
  pgdata:
```

---

## Run Order Summary

```
Step 1  →  PostgreSQL + Prisma migrate
Step 2  →  NestJS (npm run start:dev)
Step 3  →  FastAPI (python main.py)
Step 4  →  Flutter (flutter run)
```

NestJS must be running before FastAPI starts, so the `/internal/*` endpoints are available.
FastAPI and Flutter can be restarted independently at any time.
