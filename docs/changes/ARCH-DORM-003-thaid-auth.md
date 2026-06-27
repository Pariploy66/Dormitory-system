# T1-T20 Change Document

## T1 Change Title

Replace local email/password authentication with ThaID-only sign-in, and migrate
the parent identity model from phone/email to citizen ID.

- **Change ID:** ARCH-DORM-003
- **Status:** Done
- **Date:** 2026-06-27

## T2 Requirement

Parents must authenticate exclusively through ThaID (กรมการปกครอง OAuth2). Remove
username/password, email, and phone from the parent account. Identify parents by
their national ID (citizen ID) and use it to map parents to students. Record an
audit trail of app sign-in/out.

## T3 Source Evidence

- ThaID Administrative Manual v1.0.0 (BORA API) — Authentication (§6.1), Token
  (§6.2), Introspect (§6.3), Revocation (§6.4), error table, sandbox (§8–9).
- `key_sandbox.pdf` — registered RP (mfuengage) sandbox credentials + callback.
- Verified empirically against the live sandbox:
  - Auth endpoint is `GET /api/v2/oauth2/auth/` (client_id as query param) → 302 to QR page.
  - Token endpoint `POST /api/v2/oauth2/token/`, Basic `base64(client_id:client_secret)`.
  - id_token (scope=openid) carries `sub`, `pid`, `name`.

## T4 Current Behavior (Before)

- Parent registers/logs in with email + password (`POST /auth/register`, `/auth/login`).
- `parents` keyed by unique `phone` + `email`; password stored as `password_hash`.
- Students linked to parents by `parentPhone`.
- No record of app sign-in/out.

## T5 Impacted Agents

- Backend (NestJS auth + students)
- Frontend (Flutter auth feature)
- Data Model (Prisma schema + migrations)
- Security/IAM (external identity provider)

## T6 Scope

In scope: ThaID auth flow, parent schema redesign (citizenId), auth_logs table,
student linking by citizenId, Flutter login UI, env/credentials, team onboarding.

Out of scope: id_token signature verification (no JWKS in sandbox docs — POC
decodes payload only; production must verify), production ThaID credentials,
deep-link redirect (POC uses in-app webview interception).

## T7 Functional Requirements

- FR1: User signs in via ThaID; the app exchanges the authorization code for a JWT.
- FR2: A parent record is created/updated on first login, keyed by citizen ID.
- FR3: `thaidSub` and `name` are populated from the id_token.
- FR4: Students are linked to a parent by `parentCitizenId`.
- FR5: Each LOGIN and LOGOUT is recorded in `auth_logs` with IP + user agent.
- FR6: No local register/login path remains.

## T8 Acceptance Criteria

- AC1: `GET /auth/thaid/login-url` returns a ThaID URL that the sandbox answers 302. ✅
- AC2: After entering a sandbox national ID, the app reaches the dashboard with a JWT. ✅
- AC3: `parents` row has `citizen_id`, `thaid_sub`, `name`; no phone/email/password. ✅
- AC4: A LOGIN row appears in `auth_logs` after sign-in. ✅
- AC5: `/auth/register` and `/auth/login` no longer exist. ✅

## T9 API Contract

| Method | Path | Auth | Body / Result |
|---|---|---|---|
| GET | `/auth/thaid/login-url` | public | → `{ url, state }` |
| POST | `/auth/thaid` | public | `{ code }` → `{ accessToken, parentId }` |
| POST | `/auth/logout` | JWT | → `{ ok: true }` (logs LOGOUT) |
| POST | `/auth/device` | JWT | `{ fcmToken }` |
| POST | `/internal/students/link` | X-Internal-API-Key | `{ parentCitizenId, studentCode }` |

Response envelope unchanged: `{ code, message, data }`.

## T10 Data Model / Migration

Migrations: `20260627141456_thaid_only_auth`, `20260627142600_add_auth_logs`.

- `parents`: **drop** `phone`, `email`, `password_hash`; **add** `citizen_id` (unique,
  not null); `identity_provider` default → `THAID`; `thaid_sub` kept (unique, nullable).
- New `auth_logs`: `id`, `parent_id` (FK→parents, cascade), `event` (`AuthEvent`:
  LOGIN|LOGOUT), `ip_address`, `user_agent`, `created_at`; index `(parent_id, created_at desc)`.

## T11 Backend Plan / Changes

- New `modules/auth/thaid.client.ts` — `buildAuthUrl()`, `exchangeToken()` (Basic
  auth, server-side), ThaID error mapping.
- `auth.service.ts` — `getLoginUrl()`, `onThaidLogin()` (exchange → decode id_token
  → upsert parent by citizenId → issue JWT), `onLogout()`, `writeAuthLog()`.
- `auth.controller.ts` — `thaid/login-url`, `thaid`, `logout`; removed register/login.
- `jwt.strategy.ts` — payload `{ sub }` only (dropped email).
- `students.module.ts` — `linkStudentToParent` keys on `parentCitizenId` (upserts
  a parent stub when the parent has not signed in yet).
- `access-logs.service.ts` — profile returns `citizenId` instead of phone/email.
- Removed unused deps: `bcrypt`, `passport-local` (+ types).

## T12 Frontend Plan / Changes

- `features/auth/presentation/thaid_login_screen.dart` — in-app `webview_flutter`
  that loads the ThaID URL and intercepts the redirect to capture `code`.
- `login_screen.dart` — single "Login with ThaID" button; removed email/password form.
- Removed `register_screen.dart` and the `/register` route.
- `auth_bloc` — `AuthThaidLoginRequested(code)` replaces `AuthLoginRequested`.
- `api_service.dart` — `getThaidLoginUrl()`, `thaidLogin(code)`; `logout()` calls backend.
- `ParentModel` uses `citizenId`; account page + strings updated.

## T13 Security / Permission

- `client_secret` stays server-side; the app only forwards the one-time `code`.
- Authorization code is single-use, 30s TTL — exchanged immediately on the server.
- citizen ID is sensitive PII; stored for mapping. Production should hash it and
  verify the id_token signature against ThaID's JWKS.
- Secrets (`.env.local`, `firebase-service-account.json`) are gitignored.

## T14 Test Plan

- Backend: `nest build` (type/DI), live sandbox curl (auth 302, introspect for
  secret validation), end-to-end login on emulator.
- Flutter: `flutter analyze`, `flutter test` (auth/dorm bloc).
- DB: `prisma migrate status`, verify columns via introspection.

## T15 Implementation Summary

Done. ThaID-only auth works end-to-end on the Android emulator against the BORA
sandbox: login URL → QR/national-ID page → consent → code → token exchange →
parent upsert → JWT → dashboard. A `unauthorized_client` failure was traced to a
one-character OCR error in the client secret (capital `I` vs lowercase `l`),
confirmed via the introspect endpoint and fixed.

## T16 Tests Run / Evidence

- `nest build` → EXIT 0.
- `flutter analyze` → No issues found.
- `flutter test` → 24/24 passed.
- `prisma migrate status` → Database schema is up to date.
- Live sandbox: auth URL → HTTP 302 (qrcode page); introspect with correct secret
  → `invalid_token` (client auth passed); full login reached dashboard.

## T17 PRD / Docs Updated

- Added `SETUP.md` (team onboarding: clone, restore DB snapshot, env, run).
- Added `.env.example` for nestjs-backend, fastapi-integration, flutter-app.
- Added DB snapshot `nestjs-backend/prisma/db-snapshot.sql`.

## T18 Risks / Blockers / Assumptions / Decisions

- DECISION: in-app webview interception (no OS deep-link) for the POC.
- DECISION: parent identity = `thaidSub`; `citizenId` (pid) used for student mapping.
- RISK: id_token signature not verified (POC) — production needs JWKS.
- RISK: sandbox returns a mock name (`ชื่อตัว ชื่อกลาง ชื่อสกุล`); real names arrive in prod.
- ASSUMPTION: the upstream system can provide a parent's citizen ID for linking.
- NOTE: sandbox uses mfuengage credentials with redirect_uri `https://mfuengage.mfu.ac.th`.

## T19 Release / Rollback

- Release: run the two migrations (or restore the snapshot), set ThaID env, deploy.
- Rollback: previous local-auth code is in git history before this change; revert
  the commit and restore a pre-migration DB snapshot. (No production data yet — POC.)

## T20 Final Handoff

ThaID-only authentication is implemented, verified end-to-end, and pushed to
`main`. Remaining for production: obtain production ThaID credentials, verify the
id_token signature (JWKS), and confirm the upstream citizen-ID linking contract.
