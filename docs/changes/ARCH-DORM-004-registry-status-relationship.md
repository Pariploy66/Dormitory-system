# T1-T20 Change Document

## T1 Change Title

Registrar registry (guardian-by-citizen-ID + relationship), student dorm status
(graduate / move-out), access control on login, and multi-child selection.

- **Change ID:** ARCH-DORM-004
- **Status:** Done
- **Date:** 2026-06-30

## T2 Requirement

1. Only a registered guardian of an in-dorm student may use the app; anyone else
   (not a guardian, or all children graduated/moved out) is denied.
2. A parent with multiple children picks which child to view, and can switch back.
3. Track the guardian relationship (father / mother / guardian).
4. Handle student lifecycle: graduate / move out (lose access) vs move dorm (keep).

## T3 Source Evidence

- Registrar mock file `DB - ชีต1.pdf` — rows of (parent citizen ID, student code,
  external id). Citizen `1149900859119` appears twice → the 2-children case, and
  is the ThaID sandbox test login.
- Design discussion: relationship belongs on the link (not on parent or as fixed
  student columns); access = derived from having ≥1 ACTIVE student.

## T4 Current Behavior (Before)

- `parent_student_mapping` linked parent (by id) ↔ student; required a parent stub.
- Any ThaID identity could log in (empty dashboard if unlinked).
- No student status; no relationship; no multi-child UI.

## T5 Impacted Agents

Backend (auth, students, access-logs, notifications), Data Model, Frontend (dorm).

## T6 Scope

In: registry table, student status + leftAt, relationship, login access control,
DENIED audit, bulk registry sync, multi-child selection UI, mock data.
Out: production registrar integration, JWKS verification, formal dorm-move history
(deferred — access_logs gate_name already records movement).

## T7 Functional Requirements

- FR1: Login allowed only if citizen ID is a guardian of ≥1 ACTIVE student.
- FR2: Denied attempts return 403 and are recorded (auth_logs, event DENIED).
- FR3: `/me/students` returns only ACTIVE children + the relationship.
- FR4: Multi-child parent sees a picker; can switch child from Settings.
- FR5: Graduated/moved-out students are filtered; dorm-move just updates fields.

## T8 Acceptance Criteria

- AC1: `1149900859119` → 2 active children → ALLOW + picker. ✅ (verified)
- AC2: guardian of only a GRADUATED/MOVED_OUT child → DENY. ✅
- AC3: unknown citizen ID → DENY. ✅
- AC4: a student with father + mother (2 rows) → both are guardians. ✅
- AC5: nest build / flutter analyze / flutter test all green. ✅

## T9 API Contract

| Method | Path | Auth | Note |
|---|---|---|---|
| POST | `/auth/thaid` | public | 403 if not a guardian of an active student |
| GET | `/me/students` | JWT | active children + `relationship` |
| GET | `/me/students/:id/logs` | JWT | ownership via registry + ACTIVE |
| POST | `/internal/students/upsert` | key | + optional `status` |
| POST | `/internal/students/guardian` | key | `{ parentCitizenId, studentCode, relationship }` |
| POST | `/internal/registry/sync` | key | bulk `{ students[], guardians[] }` |

## T10 Data Model / Migration

Migration `20260630163618_registry_status_relationship`:
- `students`: + `status` (StudentStatus, default ACTIVE), `left_at`, `updated_at`.
- Drop `parent_student_mapping`.
- New `parent_student_registry` (parent_citizen_id, student_id FK, relationship,
  unique[parent_citizen_id, student_id]).
- `auth_logs`: `parent_id` nullable, + `citizen_id`.
- Enums: + `StudentStatus`, `Relationship`; `AuthEvent` + `DENIED`.

## T11 Backend Plan / Changes

- `auth.service.onThaidLogin`: count ACTIVE registry students for the citizen ID;
  0 → log DENIED + ForbiddenException; else upsert parent + LOGIN.
- `access-logs.service`: `onQuerys`/`onQueryLogs` resolve the parent's citizen ID
  then filter via registry + `status: ACTIVE`; students include relationship.
- `students.module`: registry-based `linkGuardian` + bulk `syncRegistry`; upsert
  student supports status (sets `leftAt` when not ACTIVE).
- `notifications.service`: FCM tokens resolved via registry citizen IDs.

## T12 Frontend Plan / Changes

- `StudentModel` + `relationship`.
- `DormState` + `selectedStudentId`; `activeStudent` / `needsChildSelection`.
- `DormBloc`: `DormSelectStudent` / `DormClearSelection`; dashboard loads the
  selected child's logs.
- `ChildSelectionScreen` (cards) shown when 2+ children and none chosen.
- Settings: "Switch child" tile (multi-child) → back to picker.
- Login: 403 → `NO_ACCESS` → shows "ไม่มีสิทธิ์เข้าถึง".

## T13 Security / Permission

- Access derived from the registry on every login (revocation takes effect on next
  login); data endpoints filter ACTIVE per request. citizen ID is PII (note for
  production: hashing + JWKS verification still pending).

## T14 Test Plan

Backend: nest build; data-level checks of active-student counts per citizen ID.
Frontend: flutter analyze + flutter test. Manual: login as 1149900859119 → picker.

## T15 Implementation Summary

Done. Registry replaces the parent-id mapping; login enforces guardian-of-active-
student; multi-child picker added; mock data seeded (6 students, 2 inactive, 7
registry rows incl. a mother for many-to-many). DB snapshot regenerated.

## T16 Tests Run / Evidence

- `nest build` → EXIT 0.
- `flutter analyze` → No issues found.
- `flutter test` → 24/24 passed.
- Logic check: 1149900859119 active=2 ALLOW; graduated/moved-out parents active=0
  DENY; unknown citizen DENY.
- `prisma migrate status` → up to date.

## T17 PRD / Docs Updated

- DB snapshot `nestjs-backend/prisma/db-snapshot.sql` regenerated (new schema+data).
- This change document.

## T18 Risks / Blockers / Assumptions / Decisions

- DECISION: relationship lives on the registry link (not parent / not student
  columns) — flexible, normalized, matches the file's row shape.
- DECISION: access = ≥1 ACTIVE student; one rule covers not-a-guardian and
  all-children-left.
- DECISION: dorm move = update dormitory/room, status stays ACTIVE (no new table).
- ASSUMPTION: registrar can supply parent citizen ID (+ optionally relationship).
- RISK: ThaID sandbox always returns 1149900859119, so the DENY path is verified
  at data level (and by temporarily removing the row), not via sandbox login.

## T19 Release / Rollback

Release: apply the migration (or restore the snapshot) + redeploy. Rollback: revert
the commit and restore a pre-migration snapshot (POC — mock data only).

## T20 Final Handoff

Implemented, verified (build/analyze/test/data), snapshot updated. Pending for
production: registrar sync integration, JWKS id_token verification, citizen-ID
hashing.
