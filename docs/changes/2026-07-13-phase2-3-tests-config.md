# T1–T20 Change Document — Phase 2 & 3: Backend Tests + Config

## T1 Change Title

| Field | Value |
|---|---|
| Change ID | DORM-PROD-P2P3 |
| Module | nestjs-backend (access-logs, common) |
| Date | 2026-07-13 |
| Owner / Agent | Systems Architect + Agent 03 Backend + Agent 06 QA |
| Status | Done |

## T2 Requirement

- User request: Production-readiness refactor, next phases — add unit tests for critical logic (F3) and remove hardcoded business values (F5).
- Success outcome: Curfew + timezone logic is pure, unit-tested, and configuration-driven.

## T3 Source Evidence

| Area | Source | What was verified |
|---|---|---|
| Curfew logic | `access-logs.service.ts` `computeStatus` (was private) | Hardcoded `22:30`/`06:00`, untestable in isolation (F3, F5) |
| Timezone logic | `access-logs.service.ts` `onCreate` (inline regex) | Duplicable, untested (F3) |
| Tests | `find *.spec.ts` = 0 in backend | No backend coverage (F3) |

## T4 Current Behavior (before)

- Curfew and timezone rules lived inline/private in the service; no tests; curfew window hardcoded.

## T5 Impacted Agents

| Agent | Required? | Reason |
|---|---|---|
| Backend | yes | Extract util, wire config |
| QA/UAT | yes | Author + run unit tests |
| Data Model / Frontend / Security | no | No schema/API/permission change |

## T6 Scope

In scope: extract `normalizeThaiTime` + `computeAccessStatus` + `parseTimeToMinutes` into `common/curfew.util.ts`; jest+ts-jest setup; 18 unit tests; curfew window from `CURFEW_START`/`CURFEW_END`.
Out of scope: Flutter/FastAPI hardening; controller/service integration tests (pure-logic first).

## T9 API Contract

No route/shape change. `status` field (`late`/`ontime`) semantics identical; window now configurable.

## T10 Data Model / Migration

None.

## T11 Backend Plan / Changes

- New `common/curfew.util.ts`: `normalizeThaiTime`, `computeAccessStatus(…, startMin?, endMin?)`, `parseTimeToMinutes`, exported default constants. All pure, no framework deps (SoC/DRY/testability = SOLID SRP + DIP).
- `access-logs.service.ts`: remove inline timezone regex + private `computeStatus`; call the util; read curfew from `process.env.CURFEW_START/END` once via `parseTimeToMinutes`.
- jest + ts-jest + `jest.config.js`; `npm test` / `test:watch` scripts.

## T13 Security / Permission

Unchanged. No new input surface (config read at startup, validated with fallback).

## T14 Test Plan

| Test ID | Type | Focus |
|---|---|---|
| TC-101 | unit | timezone: naive/Z/+07/+00 all collapse to same instant |
| TC-102 | unit | curfew edges: 22:29 ontime, 22:30 late, 05:59 late, 06:00 ontime, midnight late |
| TC-103 | unit | OUT always ontime |
| TC-104 | unit | custom curfew window honoured |
| TC-105 | unit | `parseTimeToMinutes` valid/malformed/out-of-range fallback |

## T16 Tests Run / Evidence

| Command | Result | Evidence |
|---|---|---|
| `npx jest` | pass | Test Suites: 1 passed; **Tests: 18 passed** |
| `npx tsc --noEmit` | pass | exit 0 |
| smoke: internal scan IN 23:00 | pass | 201 `{ ok:true }`; log created via refactored util (then cleaned) |

## T17 PRD / Docs Updated

| Document | Updated? | Reason |
|---|---|---|
| `nestjs-backend/.env.example` | yes | New keys `CURFEW_START`, `CURFEW_END` |
| `package.json` | yes | `test` / `test:watch` scripts + jest devDeps |

## T18 Risks / Decisions

| ID | Type | Description | Status |
|---|---|---|---|
| D-101 | Decision | Test pure logic first (highest value per NewSystem T14); service/controller integration tests deferred | closed |
| D-102 | Decision | Curfew as `HH:MM` env, parsed with safe fallback to 22:30–06:00 | closed |

## T19 Release / Rollback

- Release: optionally set `CURFEW_START`/`CURFEW_END`; defaults preserve current behaviour.
- Rollback: revert change set; no data impact.

## T20 Final Handoff

```txt
Feature: Phase 2 (backend unit tests) + Phase 3 (curfew config) — F3, F5
Status: Done, verified
Changed files: common/curfew.util.ts (+spec), access-logs.service.ts,
  jest.config.js, package.json, .env.example
Tests run: jest 18 passed; tsc pass; internal scan smoke pass
Data migration: none
Security decision: pass (no new surface)
Open risks: none new
Next owner: Phase 4 — Flutter/FastAPI hardening (logging, error handling)
```
