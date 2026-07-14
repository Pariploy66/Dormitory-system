# T1–T20 Change Document — Phase 4: Integration Tests + Health Checks

## T1 Change Title

| Field | Value |
|---|---|
| Change ID | DORM-PROD-P4 |
| Module | nestjs-backend (health module, e2e tests), docker-compose |
| Date | 2026-07-14 |
| Owner / Agent | Systems Architect + Agent 06 QA + Agent 07 Release/Ops |
| Status | Done |

## T2 Requirement

- User request: Continue production hardening — add integration tests for the core security rule and a health-check endpoint for monitoring.
- Success outcome: The crown-jewel authorization rule is proven end-to-end; orchestrators can probe readiness.

## T3 Source Evidence

| Area | Source | Verified |
|---|---|---|
| Authz rule | `access-logs.service.ts` `onQueryLogs` | Parent scoped to registry + ACTIVE student — needed real HTTP-level proof |
| JWT shape | `auth/jwt.strategy.ts`, `auth.service.ts` `signToken` | Payload `{ sub: parentId }`, HS256 with `JWT_SECRET` — lets tests mint a valid token |
| No health probe | `main.ts` (none) | No liveness/readiness endpoint for Docker/monitoring |

## T5 Impacted Agents

| Agent | Required? | Reason |
|---|---|---|
| Backend | yes | Health module |
| QA/UAT | yes | e2e authorization + guard tests |
| Release/Ops | yes | Docker healthcheck + dependency ordering |

## T6 Scope

In scope: `GET /health` (liveness), `GET /health/ready` (DB readiness, 503 on failure); e2e suite (health, guard 401s, own-child 200, foreign-child 403); Docker healthcheck + `service_healthy` dependency ordering.
Out of scope: Flutter/FastAPI changes (assessed adequate); metrics/tracing.

## T9 API Contract

| Method | Endpoint | Auth | Response | Error |
|---|---|---|---|---|
| GET | `/health` | public, no-throttle | `{status, uptimeSeconds, timestamp}` | — |
| GET | `/health/ready` | public, no-throttle | `{status:'ok', checks:{database:'up'}}` | 503 when DB down (generic message) |

## T11 Backend Plan / Changes

- `modules/health/health.controller.ts` + `health.module.ts`: liveness (no deps) and readiness (`prisma.$queryRaw SELECT 1`); `@SkipThrottle`; 503 via `ServiceUnavailableException` when DB unreachable; DB error logged server-side only (no leak).
- Register `HealthModule` in `app.module.ts`.

## T12 Test / Infra Changes

- `test/registry-authz.e2e-spec.ts` + `test/jest-e2e.json`; `test:e2e` script. Picks a real seeded parent/student at runtime (not fixed IDs); mints a JWT with the app's `JwtService`.
- `docker-compose.yml`: nestjs `healthcheck` (Node http probe — slim image has no curl); fastapi now waits on `nestjs: condition: service_healthy`.

## T13 Security / Permission

| Concern | Decision / Evidence |
|---|---|
| Authorization proof | e2e: foreign child logs → **403**; own child → 200 |
| Guard chain | e2e: `/me/*` no token → 401; `/internal/*` no key → 401 |
| Health info leak | Responses expose only coarse status; DB errors logged, not returned |

## T14 Test Plan

| Test ID | Type | Expected |
|---|---|---|
| E2E-001 | health | `/health` 200 |
| E2E-002 | health | `/health/ready` 200 (DB up) |
| E2E-003 | permission | `/me/profile` no token → 401 |
| E2E-004 | permission | `/internal/students/upsert` no key → 401 |
| E2E-005 | functional | own child logs → 200 |
| E2E-006 | permission | foreign child logs → 403 |

## T16 Tests Run / Evidence

| Command | Result | Evidence |
|---|---|---|
| `npm run test:e2e` | pass | **6 passed** incl. E2E-006 (403) and E2E-005 (200) |
| `npm test` (unit) | pass | 18 passed — isolated from e2e (rootDir src) |
| `npx tsc --noEmit` | pass | exit 0 |
| smoke `/health`, `/health/ready` | pass | 200; `{database:'up'}` |
| `docker compose config` | pass | valid with healthchecks |

## T17 PRD / Docs Updated

| Document | Updated? | Reason |
|---|---|---|
| `docs/CORE-SYSTEM.md` | new | Core-system definition (advisor request); references e2e ACs |
| `package.json` | yes | `test:e2e` script + supertest/@nestjs/testing devDeps |
| `docker-compose.yml` | yes | healthcheck + dependency ordering |

## T18 Risks / Decisions

| ID | Type | Description | Status |
|---|---|---|---|
| D-401 | Decision | e2e selects seed data at runtime → resilient to data changes; skips clearly if no logged-in parent exists | closed |
| D-402 | Decision | readiness returns 503 (not 200+degraded) so LBs stop routing | closed |
| R-401 | Risk | e2e requires a seeded DB with a logged-in parent; document as prerequisite | open (documented) |

## T19 Release / Rollback

- Release: Docker healthcheck gates fastapi start; monitoring should probe `/health/ready`.
- Rollback: revert change set; no schema/data impact.

## T20 Final Handoff

```txt
Feature: Phase 4 — integration tests + health checks
Status: Done, verified
Changed files: modules/health/*, app.module.ts, test/registry-authz.e2e-spec.ts,
  test/jest-e2e.json, package.json, docker-compose.yml, docs/CORE-SYSTEM.md
Routes: +GET /health, +GET /health/ready
Permission: unchanged (now proven by e2e)
Data migration: none
Tests run: e2e 6 passed; unit 18 passed; tsc pass; compose valid
Security decision: pass (authz 403 proven end-to-end)
Open risks: R-401 (e2e needs seeded DB) — documented
Next owner: optional — metrics/tracing, Redis rate-limit store (R-001)
```
