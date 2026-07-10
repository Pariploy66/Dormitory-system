# MFU Dormitory — Student Access Monitoring System

ระบบติดตามการเข้าหอพักนักศึกษาแบบ Real-time สำหรับผู้ปกครอง มหาวิทยาลัยแม่ฟ้าหลวง
A real-time dormitory check-in monitoring system for parents — Mae Fah Luang University.

> 📍 **แผนที่โปรเจกต์ฉบับเต็ม / Full project map:** [PROJECTMAP.md](PROJECTMAP.md)
> 🤖 **สำหรับ AI agents:** [AGENTS.md](AGENTS.md) · 🛠 **ติดตั้งละเอียด:** [SETUP.md](SETUP.md) · 🔐 **ThaID:** [docs/THAID-INTEGRATION.md](docs/THAID-INTEGRATION.md)

---

## ภาษาไทย

### ระบบนี้ทำอะไร

ผู้ปกครอง login ด้วย **ThaID** (ระบบยืนยันตัวตนภาครัฐ) → ระบบตรวจเลขบัตรประชาชนกับ**ทะเบียนผู้ปกครอง-นักศึกษา** → เห็นเฉพาะข้อมูลบุตรหลานตัวเองเท่านั้น:

- **Dashboard** — สถานะวันนี้, จำนวนเช็คอิน, กิจกรรมล่าสุดพร้อมรูปสแกนหน้า
- **History** — ประวัติเช็คอินย้อนหลัง (วันนี้ / 3 วัน / 7 วัน) พร้อมรูปจากกล้อง
- **Real-time** — สแกนหน้าปุ๊บ หน้าจอเด้งเองผ่าน WebSocket + แจ้งเตือน Push (FCM)
- **สองภาษา** — ไทย/อังกฤษ สลับได้ทั้งแอป รวมชื่อคนและชื่อตึก
- **ความปลอดภัย** — Biometric App Lock (สแกนนิ้ว/หน้า), token ใน Android Keystore, Certificate Pinning

### สถาปัตยกรรม

```
เครื่องสแกนหน้า (face-access-control / ระบบ engage)
        │  POST /internal/access-logs (X-Internal-API-Key)
        │  หรือ FastAPI poller ดึงจาก API ภายนอกแล้วส่งต่อ
        ▼
   NestJS Backend (:3000) ──Prisma──► PostgreSQL 18
        │            │
   Socket.IO      FCM Push
        ▼            ▼
      Flutter App (ผู้ปกครอง) ── login ผ่าน ThaID
```

### เริ่มใช้งานเร็ว (เครื่องใหม่)

```bash
git clone https://github.com/Pariploy66/Dormitory-system.git
cd Dormitory-system

# 1) ค่าลับ — ขอจากทีมทางแชทส่วนตัว (ไม่อยู่ใน git)
#    nestjs-backend/.env  (ดู template จาก .env.example)
#    nestjs-backend/firebase-service-account.json  (ถ้าต้องการ push notification)

# 2) ฐานข้อมูล (PostgreSQL 18) — restore ทีเดียวได้ทั้งโครงสร้าง+ข้อมูลทดสอบ
#    ใน psql/pgAdmin:  CREATE DATABASE student;
psql -U postgres -d student -f nestjs-backend/prisma/db-snapshot.sql

# 3) Backend
cd nestjs-backend
npm install --legacy-peer-deps
npx prisma generate
npm run start:dev            # → http://localhost:3000

# 4) แอปมือถือ (เปิด Android emulator ก่อน)
cd ../flutter-app
flutter pub get
flutter run                  # ThaID webview ใช้ได้เฉพาะ Android/iOS

# 5) (ตัวเลือก) FastAPI poller — ตัวเชื่อมระบบ Access Control ภายนอก
cd ../fastapi-integration
pip install -r requirements.txt
python main.py               # → http://localhost:8001
```

### ข้อมูลทดสอบ

- นักศึกษา **117 คน** (หอลำดวน 3) + log เช็คอิน 51 รายการ — นำเข้าจากไฟล์ mockup ของระบบ engage
- ผู้ปกครองทดสอบ 6 เลขบัตร (ThaID sandbox) ผูกกับนักศึกษาที่มีประวัติจริง
- สร้างข้อมูลใหม่ได้เอง: `node scripts/make-registrar.js && node scripts/import-engage.js` (ใน nestjs-backend)

---

## English

### What it does

Parents sign in with **ThaID** (Thai national digital ID) → the backend checks their citizen ID against the **parent-student registry** → they see *only their own children*:

- **Dashboard** — today's status, check-in count, latest activity with face-scan photos
- **History** — check-in history (today / 3 / 7 days) with gate camera photos
- **Real-time** — a face scan instantly updates the app via WebSocket + FCM push notification
- **Bilingual** — full Thai/English switching, including person and building names
- **Security** — biometric app lock, tokens in Android Keystore, certificate pinning

### Tech stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter 3 + flutter_bloc (feature-first architecture) |
| Backend API | NestJS 10 (TypeScript) + Prisma ORM |
| Database | PostgreSQL 18 |
| Integration | FastAPI (Python 3.11) poller with retry + dedup |
| Identity | ThaID OAuth2/OIDC (government sandbox) |
| Real-time | Socket.IO + Firebase Cloud Messaging |
| Face scan source | face_recognition (OpenCV + dlib) demo scanner / MFU engage system |

### Quick start

Same steps as the Thai section above: get secrets from the team privately (`.env`, Firebase key), restore `nestjs-backend/prisma/db-snapshot.sql` into a `student` database, then run NestJS → Flutter (→ FastAPI optionally).

### Repository layout

```
Dormitory-system/
├── nestjs-backend/       # REST API, auth, registry, access logs, FCM, Socket.IO
│   ├── prisma/           #   schema + migrations + db-snapshot.sql
│   ├── scripts/          #   data importers (Excel → DB)
│   └── data/             #   mock engage + registrar Excel files
├── fastapi-integration/  # Poller bridging the external Access Control API
├── flutter-app/          # Parent mobile app (BLoC, bilingual, biometric lock)
└── docs/                 # ThaID integration guide, user manual
```

Full breakdown of every module, table, and endpoint → **[PROJECTMAP.md](PROJECTMAP.md)**

### Secrets policy

`.env`, `firebase-service-account.json`, and the `postman/` folder are **git-ignored on purpose**. Share them through private channels only. `.env.example` files document every required variable.
