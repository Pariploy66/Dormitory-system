# CORE SYSTEM — MFU Dormitory Student Access Monitoring

นิยาม "ระบบแกน" (core system) ของโปรเจกต์: สิ่งที่**ต้องมีและต้องทำงาน**เพื่อให้ระบบบรรลุวัตถุประสงค์ แยกออกจากฟีเจอร์เสริม เพื่อใช้กำหนดขอบเขต สอบ และส่งมอบ
Defines the **core** of the system — what must exist and work for the product to fulfil its purpose — separated from optional enhancements, for scoping, defence, and handoff.

---

## 1. Core Purpose

**TH:** ให้ผู้ปกครองรู้แบบเรียลไทม์ว่าบุตรหลานเข้าหอพักแล้วหรือยัง โดยยืนยันตัวตนผู้ปกครองด้วย ThaID และให้เห็น**เฉพาะข้อมูลของลูกตัวเอง**

**EN:** Let a parent know, in real time, whether their child has checked into the dorm — with the parent's identity verified by ThaID and access restricted to *only their own children*.

---

## 2. Core Capabilities (ระบบแกน — ต้องมี)

| # | Capability | ทำไมถึงเป็นแกน | Source of truth |
|---|---|---|---|
| C1 | **Identity — ThaID login** | ไม่มีการยืนยันตัวตน = ไม่มีสิทธิ์เข้าถึงข้อมูลบุตรหลาน | `modules/auth/*`, `PROJECTMAP.md §2/§8` |
| C2 | **Authorization — registry scope** | หัวใจความปลอดภัย: เลขบัตรต้องอยู่ใน `parent_student_registry` + ลูกสถานะ ACTIVE เท่านั้น | `access-logs.service.ts` `onQueryLogs/onQuerys`, e2e 403 test |
| C3 | **Ingest — access log** | ถ้ารับ event สแกนเข้าไม่ได้ ระบบไม่มีข้อมูลจะแสดง | `POST /internal/access-logs`, `access-logs.service.ts` `onCreate` |
| C4 | **View — dashboard & history** | ผู้ปกครองต้องเห็นสถานะ + ประวัติเช็คอินของลูก | `flutter-app` Dashboard/History, `GET /me/students/:id/logs` |
| C5 | **Real-time delivery** | คุณค่าหลักคือ "เรียลไทม์": สแกนแล้วเด้งเอง (Socket.IO) + แจ้งเตือน (FCM) | `modules/events`, `modules/notifications` |

ระบบจะถือว่า "ทำงาน" ก็ต่อเมื่อ C1→C5 ครบวงจร: **login → ตรวจสิทธิ์ → รับ event → แสดง → แจ้งเตือน**

---

## 3. Core Data (ตารางแกน)

| Table | บทบาทในแกน |
|---|---|
| `students` | ตัวตนนักศึกษา (ใคร อยู่หอไหน สถานะ) |
| `parent_student_registry` | **แกนความปลอดภัย** — ใครมีสิทธิ์เห็นใคร (ผูกด้วยเลขบัตร) |
| `parents` | ผู้ปกครองที่ยืนยันตัวตนแล้ว |
| `access_logs` | เหตุการณ์เช็คอิน + รูป (ข้อมูลที่ระบบมีไว้แสดง) |

ตารางเสริม (ไม่ใช่แกน แต่สนับสนุน): `devices` (FCM), `auth_logs` (audit)

---

## 4. Core Flow (เส้นทางที่ต้องไม่ขาด)

```
สแกนหน้าที่ประตู
  → POST /internal/access-logs        (C3 ingest, key-guarded)
  → เก็บลง access_logs + normalize เวลาไทย + คำนวณ late/ontime
  → หาผู้ปกครองจาก registry            (C2)
  → FCM push + Socket.IO broadcast     (C5 real-time)
  → แอปผู้ปกครอง (login ThaID → C1, เห็นเฉพาะลูกตน → C2) แสดงผล (C4)
```

รายละเอียดเต็ม: [PROJECTMAP.md §3 End-to-end Data Flow](../PROJECTMAP.md)

---

## 5. Core vs Non-Core

| | อยู่ในแกน (core) | เสริม / hardening (non-core) |
|---|---|---|
| Auth | ThaID login, registry scope, JWT | Biometric app lock, cert pinning |
| Data | students/registry/access_logs | รูปโปรไฟล์การ์ตูน, สองภาษา (EN) |
| Ops | รับ event + แสดง + แจ้งเตือน | Docker, health-check, rate limit, structured logging |
| Integration | `/internal/access-logs` | FastAPI poller (bridge ระบบภายนอก) |

> **หมายเหตุ:** "non-core" ไม่ได้แปลว่าไม่สำคัญ — เป็นสิ่งที่ทำให้ระบบ *production-ready* (ดู `docs/changes/` Phase 1–4) แต่ระบบยัง**บรรลุวัตถุประสงค์ได้**แม้ไม่มีสิ่งเหล่านี้ ใช้เส้นนี้ตัดสินใจเวลาต้องจัดลำดับความสำคัญ

---

## 6. Core Acceptance (ระบบแกนถือว่าใช้ได้เมื่อ)

| AC | เงื่อนไข | ยืนยันด้วย |
|---|---|---|
| CORE-1 | ผู้ปกครองที่อยู่ใน registry login ThaID แล้วเห็นลูกตัวเอง | e2e: parent → own child logs 200 |
| CORE-2 | ผู้ปกครองเห็นลูกครอบครัวอื่นไม่ได้ | e2e: foreign child logs → 403 |
| CORE-3 | คนนอก registry login แล้วถูกปฏิเสธ | `auth.service` DENIED + `auth_logs` |
| CORE-4 | สแกนเข้า → log ถูกบันทึก + สถานะ late/ontime ถูกต้อง | unit: curfew 18 tests; smoke ingest |
| CORE-5 | สแกนแล้วแอปอัปเดตเอง + ผู้ปกครองได้ push | Socket.IO broadcast + FCM (Phase-เดิม) |

---

## 7. Related Docs

- [README.md](../README.md) — overview + run
- [PROJECTMAP.md](../PROJECTMAP.md) — โครงสร้าง/DB/endpoint/security ครบ
- [AGENTS.md](../AGENTS.md) — กติกาสำหรับ AI/ผู้พัฒนา
- [docs/changes/](changes/) — production hardening Phase 1–4 (T1-T20)
