# AGENTS.md — Guide for AI coding agents

คู่มือสำหรับ AI (Claude / Copilot / Cursor ฯลฯ) ที่เข้ามาทำงานกับ repo นี้ — อ่านไฟล์นี้ก่อนแก้โค้ดเสมอ
Read this before touching any code in this repository.

## What this repo is

Three services + one demo scanner make up a dormitory check-in monitoring system for parents (Mae Fah Luang University senior project):

| Path | Service | Stack | Port |
|---|---|---|---|
| `nestjs-backend/` | Main API: ThaID auth, registry authorization, access logs, FCM, Socket.IO | NestJS 10 + Prisma + PostgreSQL 18 | 3000 |
| `fastapi-integration/` | Poller bridging the external Access Control API into NestJS | FastAPI, Python 3.11 | 8001 |
| `flutter-app/` | Parent mobile app (Android/iOS; ThaID webview is mobile-only) | Flutter 3 + flutter_bloc | — |
| `D:\face-access-control` (separate folder, NOT in this repo) | Demo face scanner posting to `/internal/access-logs` | Python + OpenCV + face_recognition | — |

Architecture map with every module/table/endpoint: **PROJECTMAP.md**.

## Commands

```bash
# Backend (run from nestjs-backend/)
npm install --legacy-peer-deps        # plain `npm install` fails (Nest 10/11 peer mix)
npm run start:dev                     # dev server :3000 (watch mode)
npx tsc --noEmit -p tsconfig.json     # type gate
npx prisma generate                   # ALWAYS after schema.prisma changes (stop dev server first — Windows file lock)
npx prisma migrate deploy             # apply migrations

# Flutter (run from flutter-app/)
flutter analyze                       # gate — must be "No issues found"
flutter test                          # gate — all tests must pass
flutter run                           # needs Android emulator/device

# FastAPI (run from fastapi-integration/)
python main.py

# Data seeding (from nestjs-backend/)
node scripts/make-registrar.js        # generate data/registrar_students.xlsx (deterministic)
node scripts/import-engage.js         # wipe + reseed students/logs/registry from Excel files
node scripts/import-registry.js <xlsx>  # import a registrar Excel via /internal/registry/sync
```

## Hard rules

1. **Never commit secrets.** `.env`, `firebase-service-account.json`, `postman/` are git-ignored — keep it that way. Never print `.env` values into files that get committed.
2. **Never change ThaID credentials or `.env` values** (`THAID_*`, `DATABASE_URL`, `INTERNAL_API_KEY`, …) unless the owner explicitly asks.
3. **Migrations are append-only.** Never edit or delete existing folders under `prisma/migrations/` (checksums break). New schema change = new timestamped folder + `migrate deploy` + `prisma generate`.
4. **Gates before commit:** `flutter analyze` + `flutter test` + `npx tsc --noEmit` must all pass.
5. **After changing DB data or schema, regenerate the snapshot** so teammates stay in sync:
   ```bash
   # from nestjs-backend/ (strip ?schema=public from DATABASE_URL first)
   pg_dump "<DB_URL>" --column-inserts --no-owner --no-privileges > prisma/db-snapshot.sql
   # then delete lines starting with \restrict or \unrestrict (pg_dump 18 quirk)
   ```
6. **Windows environment.** Paths use `D:\...`; `pg_dump` lives at `C:\Program Files\PostgreSQL\18\bin\`; stopping the dev server is required before `prisma generate` (DLL lock).
7. **Docs must never lag the code.** Every code change ships with matching doc updates in the same commit: `README.md`, `AGENTS.md`, `PROJECTMAP.md` (modules/tables/endpoints/security), plus `SETUP.md`/`docs/` when steps change. Stale docs = unfinished work.

## Conventions

### Backend (nestjs-backend/src/)
- Feature modules under `src/modules/<name>/` (auth, students, access-logs, notifications, events).
- Response envelope `{ code, message, data }` via global `ResponseInterceptor` — controllers return plain data.
- Parent-facing endpoints: `AuthGuard('jwt')` + `@Authorize(resource, action)`. Service-to-service endpoints: `InternalApiKeyGuard` (`X-Internal-API-Key`), paths start with `/internal/`.
- Access control rule: a parent may only read students linked to their **citizen ID** in `parent_student_registry` AND whose status is `ACTIVE`. Never bypass this check.
- Incoming `accessTime` is always interpreted as **Thai time (UTC+7)** regardless of timezone suffix — see `access-logs.service.ts` for the normalisation contract.

### Flutter (flutter-app/lib/)
- Feature-first: `features/<name>/{bloc,domain,presentation}` + shared widgets in `shared/widgets/`.
- State = flutter_bloc + Equatable only. No Riverpod/Provider/GetX.
- All user-visible strings live in `core/l10n/strings.dart` (AppStrings.en / AppStrings.th) — never hardcode UI text in widgets.
- **Bilingual data rule:** Thai stays Thai, English stays English. Models carry both (`name`/`nameEn`, `dormitory`/`dormitoryEn`, `gateName`/`gateNameEn`); pick via `displayName(isTh)` / `locationLabel(isTh)` / `displayGate(isTh)`.
- The app shows **check-ins (IN) only** — exits are never counted or displayed. Date format is Thai Buddhist year: `d/M/yy HH:mm` (e.g. `3/7/69 14:38`) via `AccessLogModel.displayDateTime`.
- Session security: JWT in `flutter_secure_storage` (Keystore). Restored sessions start **locked** → `/unlock` (biometric via local_auth). Fresh ThaID login starts unlocked. `MainActivity` must stay `FlutterFragmentActivity`.
- Certificate pinning infra in `core/api/cert_pinning_io.dart` — enabled only when `--dart-define=PINNED_CERT_SHA256=...` is set (dev runs plain HTTP).

### Data pipeline
- Source of truth for mock data: `nestjs-backend/data/mockup_engage.xlsx` (sheets `DORM`, `Attendance IN`) + generated `registrar_students.xlsx`.
- `Attendance IN` contains non-students (security guards) — filter rows whose `User ID` is not a 10-digit number.
- Import scripts are deterministic (seeded RNG) — rerunning produces identical names/links.

## Testing accounts

Registry contains 6 real sandbox citizen IDs linked to students with real logs (see `scripts/import-engage.js` `PARENT_IDS`). ThaID sandbox host: `imauthsbx.bora.dopa.go.th`.
