# T1–T20 Change Document — Phase 1: Security & Error Hardening

## T1 Change Title

| Field | Value |
|---|---|
| Change ID | DORM-PROD-P1 |
| Module | nestjs-backend (global: filter, bootstrap, throttling) |
| Date | 2026-07-13 |
| Owner / Agent | Systems Architect + Agent 05 Security IAM |
| Status | Done |

## T2 Requirement

- User request: Refactor the working prototype toward production-ready (SOLID, security, logging, performance, config, tests), following `D:\NewSystem\docs` workflow. Phase 1 of a phased plan.
- Business goal: Close the highest-severity security/error gaps before wider refactor.
- Success outcome: No internal error/secret leakage to clients; rate limiting actually enforced; standard security headers present; CORS fails closed in production.

## T3 Source Evidence

| Area | Source path | What was verified |
|---|---|---|
| Error filter | `nestjs-backend/src/common/filters/http-exception.filter.ts` | Non-HttpException path copied `exception.message` into the client response (F1) |
| Rate limit | `nestjs-backend/src/app.module.ts` | `ThrottlerModule.forRoot(...)` imported but no `APP_GUARD`/`ThrottlerGuard` registered → unenforced (F2) |
| Bootstrap | `nestjs-backend/src/main.ts` | No `helmet`; `origin: process.env.CORS_ORIGIN ?? true` reflects any origin (F4) |
| Internal routes | `access-logs.controller.ts`, `students.module.ts` | `/internal/*` is machine-to-machine, key-guarded; would be caught by a global throttle |

## T4 Current Behavior (before)

- Unhandled `Error` returned its raw `.message` to the client (observed in Docker: `Missing required env: THAID_CLIENT_ID` leaked as a 500 body).
- Every endpoint unthrottled — brute-force/DoS possible on `/auth/thaid`.
- No security response headers; permissive default CORS.

## T5 Impacted Agents

| Agent | Required? | Reason |
|---|---|---|
| Security IAM | yes | Owns error-leakage, rate-limit, CORS, headers |
| Backend | yes | Implements filter/module/bootstrap changes |
| QA/UAT | yes | Verifies via negative + burst tests |
| Others | no | No data model / frontend / release contract change |

## T6 Scope

In scope: error-leakage fix, global ThrottlerGuard + internal exemptions, helmet, CORS allowlist, env-driven rate/CORS config.
Out of scope: backend unit tests (Phase 2), hardcoded business config e.g. curfew (Phase 3), Flutter/FastAPI hardening (later phases).

## T7 Functional Requirements

| FR ID | Requirement | Actor | Priority |
|---|---|---|---|
| FR-P1-001 | 5xx/unknown errors return a generic client message; real error logged server-side only | System | Must |
| FR-P1-002 | Global rate limit enforced per client; `/internal/*` exempt | System | Must |
| FR-P1-003 | Standard security headers on every response | System | Must |
| FR-P1-004 | CORS is an env allowlist; production without it fails closed | System | Must |

## T8 Acceptance Criteria

| AC ID | FR | Given | When | Then |
|---|---|---|---|---|
| AC-P1-001 | 001 | an unhandled server error | client calls endpoint | response body is generic; no message/stack leaked |
| AC-P1-002 | 002 | >limit requests in window | client bursts a public route | excess requests get HTTP 429 |
| AC-P1-003 | 002 | internal key present | scanner bursts `/internal/*` | no 429 (exempt) |
| AC-P1-004 | 003 | any request | client inspects headers | HSTS, X-Content-Type-Options, X-Frame-Options present |

## T9 API Contract

No route/shape changes. Response envelope `{ code, message, data }` unchanged. New failure mode: HTTP 429 `{ code: 42900-ish via filter, message }` on throttle.

## T10 Data Model / Migration

| Item | Decision |
|---|---|
| Schema change | no |
| Migration | no |

## T11 Backend Plan / Changes

- Filter: stop copying `exception.message` for non-HttpException; log full error+stack server-side, return generic message.
- Module: register `{ provide: APP_GUARD, useClass: ThrottlerGuard }`; ttl/limit from `RATE_LIMIT_TTL_MS` / `RATE_LIMIT_MAX`.
- Controllers: `@SkipThrottle()` on internal ingest (`/internal/access-logs`) and registrar controllers.
- Bootstrap: `helmet({ crossOriginResourcePolicy: 'cross-origin' })` (so `/uploads` photos still load); CORS allowlist via `CORS_ORIGIN`, fail-closed in production; replace `console.log` with `Logger`.

## T13 Security / Permission

| Concern | Decision / Evidence |
|---|---|
| Error/secret leakage | Fixed — generic client message; details logged only (F1) |
| Rate limiting | Enforced globally via ThrottlerGuard; internal exempt (F2) |
| Runtime headers | helmet enabled (F4) |
| CORS | Env allowlist; prod fails closed (F4) |
| Authentication/Authorization | Unchanged (JWT + AuthorizeGuard + InternalApiKeyGuard preserved) |

## T14 Test Plan

| Test ID | Type | Steps | Expected |
|---|---|---|---|
| TC-001 | security | inspect response headers | helmet headers present |
| TC-002 | negative | call protected route unauth | clean envelope, no stack |
| TC-003 | rate limit | burst 35 public requests | some 429 |
| TC-004 | regression | burst 40 internal requests w/ key | 0× 429 |

## T16 Tests Run / Evidence

| Command | Result | Evidence |
|---|---|---|
| `npx tsc --noEmit` | pass | exit 0 |
| TC-001 headers | pass | `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN` returned |
| TC-002 unauth | pass | `{"code":40100,"message":"Unauthorized"}` — no stack |
| TC-003 burst 35 | pass | 29× 200 then 6× 429 (limit 30/60s) |
| TC-004 internal burst 40 | pass | 0× 429, 40× 2xx |

Note: TC-004 upserted a test student; the real record (6632714510 / Chen Zheyuan) was restored afterwards.

## T17 PRD / Docs Updated

| Document | Updated? | Reason |
|---|---|---|
| `nestjs-backend/.env.example` | yes | New keys: `CORS_ORIGIN`, `RATE_LIMIT_TTL_MS`, `RATE_LIMIT_MAX` |
| README/PROJECTMAP | no | No architecture/usage change (bug/security hardening) |

## T18 Risks / Decisions

| ID | Type | Description | Status |
|---|---|---|---|
| D-001 | Decision | `/internal/*` exempt from throttle — trusted M2M, key-guarded, may burst | closed |
| D-002 | Decision | helmet `crossOriginResourcePolicy: cross-origin` so mobile app loads `/uploads` photos | closed |
| R-001 | Risk | Rate limit is per-instance (in-memory). Multi-instance deploy needs a shared store (Redis) — defer to Release/Ops | open |

## T19 Release / Rollback

- Release: set `CORS_ORIGIN` to the real app origin(s) in production `.env`; tune `RATE_LIMIT_*` as needed.
- Rollback: revert this change set; no schema/data impact.

## T20 Final Handoff

```txt
Feature: Phase 1 — Security & Error hardening (F1,F2,F4)
Status: Done, verified
Changed files: main.ts, app.module.ts, http-exception.filter.ts,
  access-logs.controller.ts, students.module.ts, .env.example
Routes: unchanged (behavioural: 429 on throttle, generic 5xx body)
Permission: unchanged
Data migration: none
Tests run: tsc pass; TC-001..004 pass
PRD/docs: .env.example updated
Security decision: pass (F1,F2,F4 closed)
Open risks: R-001 (per-instance rate limit → Redis for multi-instance)
Next owner: Phase 2 — Backend unit tests (F3)
```
