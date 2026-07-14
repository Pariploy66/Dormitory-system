# PROJECT MAP — MFU Dormitory Student Access Monitoring System

แผนที่โปรเจกต์ฉบับสมบูรณ์: ทุกโมดูล ทุกตาราง ทุก endpoint และเส้นทางข้อมูลตั้งแต่กล้องสแกนหน้าจนถึงมือถือผู้ปกครอง
The complete map of this project: every module, table, endpoint, and the full data path from the face-scan camera to the parent's phone.

---

## 1. ภาพรวม / System Overview

**TH** — ผู้ปกครองอยากรู้ว่าลูกกลับเข้าหอพักหรือยัง ระบบนี้เอาข้อมูลจากเครื่องสแกนใบหน้าหน้าหอ (ระบบ Access Control ของมหาวิทยาลัย) มาแสดงบนมือถือผู้ปกครองแบบ real-time โดยยืนยันตัวตนผู้ปกครองด้วย ThaID (บัตรประชาชนดิจิทัลภาครัฐ) และให้เห็น**เฉพาะลูกของตัวเอง**ผ่านทะเบียนผู้ปกครอง-นักศึกษาจากฝ่ายทะเบียน

**EN** — Parents want to know their child returned to the dorm. This system takes face-scan events from the university's Access Control gate, verifies the parent's identity with ThaID (Thai national digital ID), authorizes them against a registrar-issued parent-student registry, and streams the child's check-ins to the parent's phone in real time.

### Actors

| Actor | Role (TH) | Role (EN) |
|---|---|---|
| นักศึกษา / Student | สแกนหน้าเข้าหอ | Scans face at the dorm gate |
| เครื่องสแกน / Face scanner | จับภาพ + ยิง event เข้าระบบ | Captures photo + posts the event |
| ผู้ปกครอง / Parent | login ThaID, ดูประวัติลูก, รับแจ้งเตือน | Logs in with ThaID, views history, receives push |
| ฝ่ายทะเบียน / Registrar | เจ้าของข้อมูล นศ. + ทะเบียนผู้ปกครอง | Owns student info + guardian registry |

---

## 2. Architecture

```
┌─────────────────────────┐        ┌──────────────────────────┐
│  Face scanner (demo)    │        │  MFU engage / external   │
│  D:\face-access-control │        │  Access Control API      │
│  OpenCV+face_recognition│        └───────────┬──────────────┘
└───────────┬─────────────┘                    │ poll every 30s
            │ POST /internal/access-logs       ▼
            │ (base64 photos)        ┌──────────────────────────┐
            │                        │  fastapi-integration     │
            │                        │  :8001 — retry + dedup   │
            │                        └───────────┬──────────────┘
            │                                    │ POST /internal/access-logs
            ▼                                    ▼
┌──────────────────────────────────────────────────────────────┐
│                    nestjs-backend  :3000                     │
│  auth (ThaID OAuth2) · registry authorization · access logs  │
│  photo storage (/uploads) · FCM push · Socket.IO gateway     │
└──────┬────────────────────┬─────────────────┬────────────────┘
       │ Prisma             │ Socket.IO       │ FCM
       ▼                    ▼                 ▼
┌──────────────┐   ┌─────────────────────────────────┐
│ PostgreSQL 18│   │  flutter-app (parent's phone)   │
│  7 tables    │   │  ThaID login → biometric lock   │
└──────────────┘   └─────────────────────────────────┘
```

---

## 3. เส้นทางข้อมูลครบวงจร / End-to-end Data Flow

**สายที่ 1 — การสแกนเข้า (scan → phone), ใช้เวลา < 2 วินาที:**

1. นักศึกษาสแกนหน้าที่ประตู → เครื่องสแกนจับคู่ใบหน้ากับ `known_faces/`
2. เครื่องสแกนยิง `POST /internal/access-logs` พร้อม `photoBase64` (รูปอ้างอิง) + `scanPhotoBase64` (ภาพจากกล้อง ณ วินาทีนั้น)
3. NestJS ตรวจ `X-Internal-API-Key` → normalize เวลาเป็นไทย (UTC+7) → เซฟรูปเป็นไฟล์ใน `uploads/access-logs/` → upsert ลง `access_logs` (กันซ้ำด้วย unique key `student+time+type`)
4. NestJS หาผู้ปกครองของ นศ. คนนี้จาก `parent_student_registry` → ยิง **FCM push** "…entered the dormitory at HH:mm" (เฉพาะขาเข้า) ไปทุกเครื่องที่ login ค้างไว้
5. NestJS broadcast ผ่าน **Socket.IO** → แอปที่เปิดอยู่ refresh หน้าจอเองทันที

**สายที่ 2 — ผู้ปกครองเปิดแอป:**

1. เปิดแอป → มี session เดิมใน secure storage → เข้าหน้า **Unlock** สแกนนิ้ว/หน้า/PIN เครื่อง (local_auth) / ไม่มี session → หน้า **Login with ThaID**
2. ThaID login: แอปขอ URL จาก `GET /auth/thaid/login-url` → เปิด webview → ผู้ใช้ยืนยันกับ DOPA → แอปดัก authorization code ส่งเข้า `POST /auth/thaid`
3. Backend แลก code เป็น id_token กับ ThaID → ได้ **เลขบัตรประชาชน (pid)** → เช็คใน `parent_student_registry` ว่ามีลูกสถานะ ACTIVE ไหม → **ไม่มี = ปฏิเสธ (NO_ACCESS + จด auth_logs DENIED)** / มี = สร้าง/อัปเดต `parents` + ออก JWT ของระบบเอง
4. แอปเรียก `GET /me/students` (ลูกทุกคน) → ลูก 2 คนขึ้นไปเจอหน้าเลือกลูกก่อน → `GET /me/students/:id/logs?days=7` แสดง Dashboard/History

**สายที่ 3 — ข้อมูลจากฝ่ายทะเบียน:**

ไฟล์ Excel ฝ่ายทะเบียน/engage → สคริปต์ `import-engage.js` หรือ `POST /internal/registry/sync` → ตาราง `students` + `parent_student_registry`

---

## 4. แผนที่โค้ดรายเซอร์วิส / Per-service Code Map

### 4.1 `nestjs-backend/` (API หลัก)

| Path | หน้าที่ (TH) | Responsibility (EN) |
|---|---|---|
| `src/main.ts` | bootstrap: validation, envelope, Socket.IO adapter, CORS, body 10MB, serve `/uploads` | app bootstrap + static photo serving |
| `src/modules/auth/` | ThaID OAuth2 ทั้ง flow, ออก JWT, logout, ลงทะเบียน device (FCM), จด auth_logs | ThaID flow, JWT issuing, device registration, auth audit |
| `src/modules/students/` | upsert นศ., ผูกผู้ปกครอง, bulk `registry/sync` (จำลองไฟล์ฝ่ายทะเบียน) | student upsert, guardian link, bulk registrar sync |
| `src/modules/access-logs/` | รับ event สแกน (URL/base64 photos), คิวรีประวัติ + คำนวณ late (เคอร์ฟิว 22:30–05:59), โปรไฟล์/รายชื่อลูก | scan ingestion, history query + curfew status, profile |
| `src/modules/notifications/` | Firebase Admin init (crash-safe), ส่ง push เฉพาะขาเข้า, ล้าง token เสีย | FCM push (IN only), invalid-token cleanup |
| `src/modules/events/` | Socket.IO gateway — broadcast `log:created` | realtime gateway |
| `src/common/` | ResponseInterceptor `{code,message,data}`, HttpExceptionFilter, InternalApiKeyGuard, AuthorizeGuard + `@Authorize` | cross-cutting: envelope, guards |
| `prisma/` | schema, 7 migrations, `db-snapshot.sql` (โครงสร้าง+ข้อมูลทดสอบครบ) | schema + migrations + full snapshot |
| `scripts/` | `make-registrar.js` (สร้างไฟล์ทะเบียน mockup), `import-engage.js` (ล้าง+ลงข้อมูลจริง), `import-registry.js` (Excel→sync) | data pipeline scripts |
| `data/` | `mockup_engage.xlsx` (DORM 117 / Attendance IN 67), `registrar_students.xlsx` | source Excel files |
| `uploads/access-logs/` | รูปสแกนที่เครื่องสแกนส่งมา (เสิร์ฟผ่าน `/uploads/...`) | stored gate photos |
| `Dockerfile` (backend + fastapi), root `docker-compose.yml` | รันทั้ง stack คำสั่งเดียว (postgres18 + nestjs + fastapi); Postgres auto-load snapshot | one-command containerised stack |

### 4.2 `fastapi-integration/` (ตัวเชื่อมระบบภายนอก)

| Path | หน้าที่ |
|---|---|
| `app/services/poller.py` | ลูป poll ทุก 30 วิ — ดึง event ใหม่จาก external API แล้วส่งต่อ NestJS |
| `app/services/external_client.py` | เรียก external API + Tenacity retry (exponential backoff 5 ครั้ง) |
| `app/services/nestjs_client.py` | forward เข้า `/internal/access-logs` (รวม photo_url/scan_photo_url) |
| `app/services/state.py` | watermark กันดึง event ซ้ำ (dedup ชั้นที่ 1; ชั้นที่ 2 คือ Prisma upsert) |
| `app/models/schemas.py` | Pydantic models + กติกา timezone: naive time = เวลาไทย (+07:00) |

### 4.3 `flutter-app/` (แอปผู้ปกครอง — feature-first + BLoC)

| Path | หน้าที่ |
|---|---|
| `lib/app/` | `app.dart` (MultiBlocProvider + MaterialApp.router), `router.dart` (go_router: `/login` → `/unlock` → `/home` ตามสถานะ auth+lock) |
| `lib/core/api/` | Dio client + JWT interceptor + **certificate pinning** (`cert_pinning_io.dart`, เปิดใช้ผ่าน `--dart-define=PINNED_CERT_SHA256`) |
| `lib/core/auth/token_storage.dart` | JWT ใน **flutter_secure_storage** (Android Keystore / iOS Keychain) |
| `lib/core/l10n/strings.dart` | ข้อความ UI ทุกคำ 2 ภาษา (AppStrings.th / .en) |
| `lib/core/services/` | ApiService (ทุก endpoint), FcmService, SocketService |
| `lib/features/auth/` | AuthBloc (check/thaid-login/logout/**unlocked**), LoginScreen (ThaID webview), **UnlockScreen** (biometric) |
| `lib/features/dorm/` | DormBloc (students/logs/filter/selected-child + realtime refresh), Dashboard/History/Settings, ChildSelection |
| `lib/features/locale/` | LocaleBloc สลับ ไทย↔อังกฤษ ทั้งแอป |
| `lib/shared/widgets/` | ActivityTile, LogList+HistoryTile (รูปสแกนสี่เหลี่ยม 72px), MfuCustomAppBar (โหมดปุ่ม Back สำหรับหลายลูก) ฯลฯ |

### 4.4 `D:\face-access-control` (เครื่องสแกนเดโม — แยกนอก repo)

`face_scanner.py` เปิดกล้อง → จับคู่หน้ากับ `known_faces/<id>.jpg` → cooldown 60 วิ/คน → ส่ง event + รูป base64 · `mock_generator.py` ยิง event จำลองโดยไม่ใช้กล้อง · `config.py` ชี้ `API_URL` ไปเครื่องที่รัน backend

---

## 5. ฐานข้อมูล / Database (PostgreSQL 18, Prisma)

```
parents ─────┐ (จับคู่ด้วย citizen_id — ไม่ใช่ FK)
             │
devices ──► parents          parent_student_registry ──► students ──► access_logs
auth_logs ─► parents(nullable)         (ทะเบียนผู้ปกครอง)
```

| Table | เก็บอะไร | คอลัมน์เด่น |
|---|---|---|
| `students` | นักศึกษา (จากฝ่ายทะเบียน + engage) | `student_code`, `name`/`name_en`, `photo_url` (รูปทะเบียน), `dormitory`/`dormitory_en`, `room_number`, `status` (ACTIVE/GRADUATED/MOVED_OUT) |
| `parent_student_registry` | ใครเป็นผู้ปกครองของใคร (many-to-many) | `parent_citizen_id` ← **ผูกด้วยเลขบัตร ไม่ใช่ FK** โหลดล่วงหน้าได้ก่อนผู้ปกครองเคย login, `relationship` (FATHER/MOTHER/GUARDIAN/OTHER) |
| `parents` | ผู้ปกครองที่เคย login ThaID | `citizen_id` (unique), `thaid_sub`, `identity_provider` |
| `access_logs` | event สแกนแต่ละครั้ง | `access_time`, `type` (IN/OUT), `gate_name`/`gate_name_en`, `photo_url` (รูปภาพ), `scan_photo_url` (รูปภาพสแกน), unique `(student, time, type)` กันซ้ำ |
| `devices` | FCM token ต่อเครื่อง | ผู้ปกครอง 1 คนหลายเครื่องได้ |
| `auth_logs` | audit การ login | `event` (LOGIN/LOGOUT/**DENIED**), เก็บ citizen_id คนที่โดนปฏิเสธด้วย |
| `_prisma_migrations` | บันทึกภายในของ Prisma | ห้ามแก้ |

**ทำไม registry ผูกด้วยเลขบัตร:** ฝ่ายทะเบียนส่งรายชื่อผู้ปกครองมาก่อนที่ผู้ปกครองจะเคยเปิดแอป — ถ้าใช้ FK ไป `parents` จะผูกไม่ได้จนกว่าเขา login ครั้งแรก

---

## 6. API Reference

### Public / Parent (JWT)

| Method | Path | Auth | คืนอะไร |
|---|---|---|---|
| GET | `/auth/thaid/login-url` | — | ThaID authorization URL + state |
| POST | `/auth/thaid` | — | แลก code → `{ token, parent }` (ปฏิเสธถ้าไม่อยู่ใน registry) |
| POST | `/auth/logout` | JWT | จด LOGOUT ใน auth_logs |
| POST | `/auth/device` | JWT | ลงทะเบียน FCM token |
| GET | `/me/profile` | JWT | ข้อมูลผู้ปกครอง |
| GET | `/me/students` | JWT | ลูกที่ ACTIVE (ชื่อ 2 ภาษา + รูปทะเบียน + relationship) |
| GET | `/me/students/:id/logs?days=N` | JWT | log + `status` late/ontime + URL รูปแบบ absolute |
| GET | `/health` | public | liveness — `{status, uptimeSeconds}` (monitoring/Docker) |
| GET | `/health/ready` | public | readiness — เช็ค DB, 503 ถ้า DB ล่ม |

### Internal (`X-Internal-API-Key`)

| Method | Path | ใครเรียก | ทำอะไร |
|---|---|---|---|
| POST | `/internal/access-logs` | เครื่องสแกน / FastAPI | รับ event (+รูป URL หรือ base64) |
| POST | `/internal/students/upsert` | ฝ่ายทะเบียน/Postman | เพิ่ม/แก้ นศ. รายคน |
| POST | `/internal/students/guardian` | ฝ่ายทะเบียน/Postman | ผูกผู้ปกครอง 1 คู่ |
| POST | `/internal/registry/sync` | ฝ่ายทะเบียน/สคริปต์ | โหลดทั้งไฟล์ทะเบียน (students[] + guardians[]) — idempotent |

ทุก response ห่อ envelope `{ code, message, data }` · Static: `GET /uploads/access-logs/<file>.jpg`

---

## 7. Real-time & Notifications

| ช่องทาง | เทคโนโลยี | พฤติกรรม |
|---|---|---|
| หน้าจอเด้งเอง | Socket.IO (`log:created`) | แอปเปิดอยู่ → DormBloc refresh ทันที ไม่ต้องปัดรีเฟรช |
| แจ้งเตือนนอกแอป | FCM (Firebase Admin) | เฉพาะ**ขาเข้า**: "\<ชื่อ\> entered the dormitory at \<เวลา\>" — ส่งทุกเครื่องของผู้ปกครองทุกคนของ นศ. คนนั้น |
| ตัวสำรอง | Timer poll 30 วิ ใน DormBloc | กันกรณี socket หลุด |

---

## 8. Security (7 ชั้น / 7 layers)

1. **ThaID OAuth2** — ยืนยันตัวตนด้วยระบบภาครัฐ ไม่มีรหัสผ่านของเราเอง (sandbox: `imauthsbx.bora.dopa.go.th`)
2. **Registry authorization** — เลขบัตรต้องอยู่ใน `parent_student_registry` + ลูกสถานะ ACTIVE เท่านั้น; คนแปลกหน้า = NO_ACCESS + จด DENIED; ทุกคิวรี log เช็คสิทธิ์ซ้ำที่ระดับ service
3. **JWT ของระบบเอง** — ทุก endpoint ฝั่งผู้ปกครองต้องมี Bearer token + `@Authorize(resource, action)`
4. **Internal API Key** — service-to-service (`/internal/*`) แยกจาก JWT โดยสิ้นเชิง
5. **Secure Storage** — JWT เก็บใน Android Keystore / iOS Keychain (flutter_secure_storage) ไม่ใช่ SharedPreferences
6. **Biometric App Lock** — session เดิมเปิดแอปใหม่ต้องผ่านสแกนนิ้ว/หน้า/PIN เครื่อง (local_auth); login ThaID สดไม่ต้องซ้ำ
7. **Certificate Pinning** — ตรวจ SHA-256 ของ cert ฝั่ง server ตอน build production (`--dart-define=PINNED_CERT_SHA256`) กัน MITM บน Wi-Fi สาธารณะ

เสริม: ValidationPipe whitelist ทุก DTO · ค่าลับทุกตัวอยู่นอก git (`.env`, Firebase key) · audit trail ใน `auth_logs`

---

## 9. ระบบสองภาษา / Bilingual Design

กติกา: **ไทยคือไทย อังกฤษคืออังกฤษ — ไม่แปลข้ามภาษา**

- ข้อความ UI: `core/l10n/strings.dart` (AppStrings.th / .en) สลับด้วย LocaleBloc (ไอคอนลูกโลกหน้า login / เมนู Settings)
- ข้อมูลจากระบบ: เก็บคู่ในฐานข้อมูล — `name`/`name_en`, `dormitory`/`dormitory_en`, `gate_name`/`gate_name_en` (ที่มา: engage ให้ `BUILDNAME` + `BUILDNAME_ENG`)
- ฝั่งแอปเลือกผ่าน `displayName(isTh)` / `locationLabel(isTh)` / `displayGate(isTh)` — ถ้าไม่มีค่าอังกฤษ fallback เป็นไทย
- วันที่ใช้ปี พ.ศ. 2 หลัก: `3/7/69 14:38`

---

## 10. Mock Data Pipeline

```
mockup_engage.xlsx ──┐
 (DORM 117 แถว,      ├─► make-registrar.js ─► registrar_students.xlsx
  Attendance IN 67)  │    (ชื่อจริง 23 จาก Attendance + generate 94, deterministic)
                     │
                     └─► import-engage.js ─► DB:
                           students 117 (2 ภาษา + รูปการ์ตูน DiceBear)
                           access_logs 51 (กรอง รปภ. 16 แถวออก, รูป pravatar คงที่ต่อคน)
                           registry: เลขบัตรทดสอบ 6 เลข → นศ. 7 คนที่มี log จริง
```

ยิงข้อมูลเพิ่มเอง: Postman (`insertStudent`, `linkStudent`, `registrySync`, `ScanIN`) หรือ `mock_generator.py` / `face_scanner.py`

---

## 11. Environment Variables (สรุป — ค่าจริงไม่อยู่ใน git)

| ไฟล์ | ตัวแปรหลัก |
|---|---|
| `nestjs-backend/.env` | `DATABASE_URL`, `JWT_SECRET`, `INTERNAL_API_KEY`, `THAID_BASE_URL/CLIENT_ID/CLIENT_SECRET/REDIRECT_URI/SCOPE/API_KEY`, `FIREBASE_SERVICE_ACCOUNT_PATH` |
| `fastapi-integration/.env` | `EXTERNAL_API_BASE_URL`, `NESTJS_BASE_URL`, `INTERNAL_API_KEY` (ต้องตรงกับ NestJS), `POLL_INTERVAL_SECONDS` |
| Flutter (build-time) | `--dart-define=API_BASE_URL=...`, `--dart-define=PINNED_CERT_SHA256=...` (production) |

---

## 12. อภิธานศัพท์ / Glossary

| คำ | ความหมาย |
|---|---|
| ThaID | ระบบยืนยันตัวตนดิจิทัลของกรมการปกครอง (DOPA) — ให้ pid = เลขบัตรประชาชน |
| pid / citizen ID | เลขบัตรประชาชน 13 หลัก — กุญแจจับคู่ผู้ปกครอง↔ทะเบียน |
| Registry | ตาราง `parent_student_registry` จากฝ่ายทะเบียน — หัวใจของการตัดสิทธิ์ |
| engage | ระบบ Access Control จริงของมหาวิทยาลัย (ที่มาของไฟล์ mockup) |
| รูปภาพ / photo_url | รูปอ้างอิง/โปรไฟล์ (ต่อ นศ. ในตาราง students, ต่อ event ในตาราง access_logs) |
| รูปภาพสแกน / scan_photo_url | ภาพจากกล้อง ณ วินาทีสแกน — โชว์ในหน้า History |
| Watermark | timestamp ล่าสุดที่ FastAPI ประมวลแล้ว — กันดึง event ซ้ำ |
| late / ontime | เข้าหลังเคอร์ฟิว 22:30–05:59 (เวลาไทย) = late — คำนวณฝั่ง backend เท่านั้น |
