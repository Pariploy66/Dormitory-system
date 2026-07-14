# Limitations & Production Roadmap

เอกสารสำหรับใช้ในการสอบ/ส่งมอบ: สรุปว่าระบบทำอะไรได้แล้ว, ข้อจำกัดที่รู้ตัว, และสิ่งที่ต้องทำก่อนขึ้นใช้งานจริงกับมหาวิทยาลัย
Defense / handoff document: what the system already does, its known limitations, and what remains before real university production.

> ใช้เป็นฐานทำสไลด์หน้า "Limitations & Future Work" — เรียงจากพร้อมแล้ว → ข้อจำกัด → roadmap

---

## 1. สถานะปัจจุบัน / Current Maturity

**โค้ดและสถาปัตยกรรมอยู่ในระดับ production-grade** — เกินระดับ prototype ไปมาก แต่ยังไม่พร้อม *deploy จริง* เพราะติด dependency ภายนอก (ดู §3)

| ด้าน / Area | สถานะ | หลักฐาน / Evidence |
|---|---|---|
| Architecture (SOLID, modular, SoC) | ✅ พร้อม | `PROJECTMAP.md`, feature modules, pure utils |
| Authentication (ThaID OAuth2) | ✅ ใช้งานได้ (sandbox) | `modules/auth`, login flow demo |
| Authorization (registry scope) | ✅ พิสูจน์แล้ว | e2e test: foreign child → **403**, own child → 200 |
| Error handling (ไม่รั่ว internal) | ✅ | `http-exception.filter.ts` |
| Security (headers, rate limit, CORS) | ✅ | helmet, ThrottlerGuard, e2e |
| Testing | ✅ **49 tests** | unit 18 + integration 6 + Flutter 25 |
| Config management (ไม่ hardcode) | ✅ | env-driven curfew, rate limit, CORS |
| Real-time + Push | ✅ | Socket.IO + FCM |
| Health check + Docker | ✅ | `/health/ready`, compose + healthcheck |
| Bilingual (TH/EN) | ✅ | ทั้งแอป รวมชื่อคน/ตึก |
| Mobile security | ✅ | biometric lock, Keystore, cert-pinning |
| เอกสาร / Docs | ✅ | README, PROJECTMAP, AGENTS, CORE-SYSTEM, T1-T20 change docs |

**คะแนนความพร้อมโดยประมาณ:** prototype 3/10 · production จริง 10/10 · **ปัจจุบัน ≈ 7/10**

---

## 2. ข้อจำกัดที่รู้ตัว / Known Limitations

จัดลำดับตามความร้ายแรงต่อการใช้งานจริง 🔴 = ห้ามขึ้น prod / 🟠 = ควรทำก่อน / 🟡 = ทำเพื่อ scale

| ระดับ | Limitation | รายละเอียด | อยู่ในโค้ด (evidence) |
|---|---|---|---|
| 🔴 | **ThaID signature ยังไม่ verify** | POC ยังไม่ตรวจลายเซ็น id_token (JWKS ของ BORA/DOPA ไม่มีใน sandbox docs) → ในทางทฤษฎีปลอม token ได้ | `auth.service.ts` `NOTE (POC): signature is NOT verified` |
| 🔴 | **PDPA compliance** | เก็บเลขบัตร ปชช. + รูปหน้านักศึกษา = ข้อมูลส่วนบุคคลอ่อนไหว ยังไม่มี consent flow, encryption-at-rest, data retention policy | — (ต้องมีนโยบาย) |
| 🔴 | **ข้อมูลเป็น mockup** | นักศึกษา 117 คน + เลขบัตรผู้ปกครองเป็นชุดทดสอบ ยังไม่เชื่อม feed จริงจากสำนักทะเบียน/engage | `data/*.xlsx`, `scripts/import-*.js` |
| 🟠 | **ยังเป็น HTTP** | ยังไม่มี TLS/HTTPS + domain จริง (dev รันบน LAN) | `constants.dart`, `main.ts` |
| 🟠 | **FastAPI ต่อ mock API** | poller ชี้ไป external API จำลอง ยังไม่ใช่ Access Control จริงของมหาลัย | `fastapi-integration/.env` |
| 🟠 | **ไม่มี backup/encryption at-rest** | DB + รูปใน `uploads/` ยังไม่มี backup อัตโนมัติ / เข้ารหัส | — |
| 🟡 | **Rate limit เป็น in-memory** | ต่อ instance — ถ้ารันหลาย instance ต้องใช้ Redis (จดไว้ R-001) | `app.module.ts` |
| 🟡 | **ไม่มี CI/CD, monitoring** | ยังต้อง test/deploy เอง ยังไม่มี Prometheus/Sentry | — |

---

## 3. Production Roadmap

แยกเป็น "ต้องขอจากภายนอก (blocker)" กับ "ทีมทำเองได้ (code/ops)"

### 3.1 Blockers — ต้องประสานงานก่อน (owner: ทีม + มหาวิทยาลัย)

| # | สิ่งที่ต้องได้ | จากใคร | ปลดล็อกอะไร |
|---|---|---|---|
| B1 | ThaID production credentials + JWKS public key | BORA/DOPA (ผ่านมหาลัย) | verify signature จริง (ปิด 🔴 อันดับ 1) |
| B2 | นโยบาย PDPA + ผู้รับผิดชอบ (DPO) | มหาวิทยาลัย | consent/retention/encryption ที่ถูกกฎหมาย |
| B3 | Data feed จริง (export ทะเบียน + Access Control API) | สำนักทะเบียน / ระบบ engage | แทน mock data + ต่อ scanner จริง |
| B4 | Server + domain + TLS cert | ฝ่าย IT มหาวิทยาลัย | deploy จริง (HTTPS) |

### 3.2 Code/Ops — ทีมทำเองได้ (เตรียมรอ blocker)

| ลำดับ | งาน | สถานะ |
|---|---|---|
| 1 | ThaID signature verification (scaffold รอ JWKS จาก B1) | รอทำ |
| 2 | Environment tiers (.env.preprod/.prod) + `docker-compose.server.yml` + Nginx reverse proxy + TLS | รอทำ |
| 3 | Encryption-at-rest + DB backup script + data retention job | รอทำ |
| 4 | Redis rate-limit store (multi-instance) | รอทำ |
| 5 | Structured request logging + error tracking (Sentry-ready) | รอทำ |
| 6 | CI/CD (GitHub Actions: test + build ทุก push) | รอทำ |

---

## 4. สรุปสำหรับนำเสนอ / Defense Summary

**ประโยคเปิด:**
> "ระบบพัฒนาถึงระดับ production-grade codebase — สถาปัตยกรรม, ความปลอดภัย, การทดสอบ (49 tests), และเอกสารครบตามมาตรฐาน โดยเรารู้ชัดว่าอะไรยังไม่พร้อมสำหรับ production จริง และมี roadmap ที่ชัดเจน"

**ถ้ากรรมการถามเรื่องความปลอดภัย/PDPA:**
> "เรา identify ไว้แล้วว่า ThaID signature verification และ PDPA compliance เป็น 2 dependency หลักก่อนขึ้นจริง — ตัวโค้ดออกแบบให้พร้อมเสียบเมื่อได้ production credentials และนโยบายจากมหาวิทยาลัย"

**จุดขาย 3 ข้อ:**
1. เชื่อมระบบภาครัฐจริง (ThaID) + ระบบมหาลัย (engage) — ไม่ใช่ระบบปิดจำลอง
2. Production hardening + testing จริง (49 tests, e2e พิสูจน์ authorization)
3. รู้ limitation ตัวเอง + มี roadmap = maturity ระดับวิศวกร ไม่ใช่แค่ทำให้ทำงานได้

---

## 5. อ้างอิง / References

- [CORE-SYSTEM.md](CORE-SYSTEM.md) — นิยามระบบแกน
- [PROJECTMAP.md](../PROJECTMAP.md) — สถาปัตยกรรม/DB/endpoint/security
- [docs/changes/](changes/) — production hardening Phase 1–4 (T1-T20)
- โค้ดหลักฐาน: `auth.service.ts` (ThaID), `access-logs.service.ts` (authz), `test/registry-authz.e2e-spec.ts` (403 proof)
