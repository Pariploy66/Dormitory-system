# Postman — Dormitory API

ชุดทดสอบ API ของ backend พร้อมใช้ import เข้า Postman ได้เลย

## วิธี import

1. เปิด Postman → **Import** → เลือกไฟล์ `Dormitory-API.postman_collection.json`
2. จะได้ collection **"Dormitory API"** มี 3 กลุ่ม + 10 requests

## ก่อนยิง — 2 อย่าง

1. **รัน backend:** `cd nestjs-backend && npm run start:dev`
2. Postman มุมขวาล่าง → เปลี่ยนเป็น **Desktop Agent** (ไม่งั้นยิง localhost ไม่ได้)

## ตั้งค่า Variables (แท็บ Variables ของ collection)

| ตัวแปร | ค่า | ใช้ตอน |
|---|---|---|
| `baseUrl` | `http://localhost:3000` | ทุก request |
| `internalKey` | `change-me-internal-secret-key` | กลุ่ม Internal |
| `jwt` | (ว่าง — ได้จากตอน login ThaID) | กลุ่ม Parent |
| `studentId` | (UUID นักศึกษา) | ดู log รายคน |

## กลุ่ม requests

- **Internal** (ใช้ `X-Internal-API-Key`) — ยิงเทสต์ได้เลย
  - Scan IN / OUT (จำลองประตู) · Upsert student · Link guardian · **Registry sync (โหลดข้อมูลทั้งชุด)**
- **Auth** — ThaID login-url · logout
- **Parent** (ใช้ `Bearer {{jwt}}`) — profile · my students · student logs
  - *ต้องมี JWT ก่อน (ได้จากการ login ThaID จริงในแอป) — เอามาใส่ตัวแปร `jwt`*

## เริ่มยังไง

ยิง **Internal → Scan IN** ก่อน → เปิด Prisma Studio ดูตาราง `access_logs` ว่ามี record เพิ่มไหม
