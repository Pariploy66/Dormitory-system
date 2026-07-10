/**
 * import-engage.js — โหลดข้อมูลจริง (mockup ระบบ engage + ไฟล์ฝ่ายทะเบียน) ลง DB
 *
 * อ่าน:
 *   data/mockup_engage.xlsx       (sheet DORM = ใครพักห้องไหน, Attendance IN = log สแกนเข้า)
 *   data/registrar_students.xlsx  (ชื่อไทย/อังกฤษ + รูปทะเบียน — สร้างด้วย make-registrar.js)
 *
 * ทำ:
 *   1. ล้างข้อมูลชุดเก่า (access_logs, registry, students) — ไม่แตะ parents/devices/auth_logs
 *   2. ลง students 117 คน (ชื่อ 2 ภาษา, ตึก 2 ภาษา, ห้อง, รูปทะเบียน, ACTIVE)
 *   3. ลง access_logs จาก Attendance IN (กรองแถวที่ไม่ใช่ นศ. เช่น รปภ. ออก)
 *      - เวลา = ตามไฟล์ (เวลาไทย)  - รูปสแกน/รูปอ้างอิง = placeholder หน้าคน (คงที่ต่อคน)
 *   4. สุ่มผูกผู้ปกครอง (เลขบัตรทดสอบจริง 6 เลข) กับ นศ. ที่มี log
 *      - 1149900859119 ได้ 2 คน (เคสลูกหลายคน)  - สุ่มแบบ deterministic รันซ้ำได้ผลเดิม
 *
 * วิธีใช้:  node scripts/make-registrar.js && node scripts/import-engage.js
 */
const path = require('path');
const XLSX = require('xlsx');
const { PrismaClient } = require('@prisma/client');

const DATA_DIR = path.join(__dirname, '..', 'data');
const GATE_TH = 'หอพักลำดวน 3';
const GATE_EN = 'Lamduan 3 Dormitory';

// ผู้ปกครองทดสอบ (เลขบัตรจริงของทีม) — คนแรกได้ลูก 2 คน
const PARENT_IDS = [
  { citizenId: '1149900859119', children: 2, relationship: 'FATHER' },
  { citizenId: '3301201232653', children: 1, relationship: 'MOTHER' },
  { citizenId: '3640400263229', children: 1, relationship: 'FATHER' },
  { citizenId: '3101401511876', children: 1, relationship: 'GUARDIAN' },
  { citizenId: '3400700708503', children: 1, relationship: 'FATHER' },
  { citizenId: '1141400113455', children: 1, relationship: 'MOTHER' },
];

function rng(seed) {
  return function () {
    seed |= 0; seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

async function main() {
  const engage = XLSX.readFile(path.join(DATA_DIR, 'mockup_engage.xlsx'));
  const registrar = XLSX.readFile(path.join(DATA_DIR, 'registrar_students.xlsx'));
  const dorm = XLSX.utils.sheet_to_json(engage.Sheets['DORM'], { defval: '' });
  const att = XLSX.utils.sheet_to_json(engage.Sheets['Attendance IN'], { defval: '' });
  const reg = XLSX.utils.sheet_to_json(registrar.Sheets['REGISTRAR'], { defval: '' });
  const regById = new Map(reg.map((r) => [String(r.STUDENTID), r]));

  const p = new PrismaClient();

  // ── 1. ล้างชุดเก่า ─────────────────────────────────────────────
  await p.accessLog.deleteMany({});
  await p.parentStudentRegistry.deleteMany({});
  await p.student.deleteMany({});
  console.log('ล้างข้อมูลเก่า: students / access_logs / registry');

  // ── 2. students ───────────────────────────────────────────────
  // DORM อาจมีรหัสซ้ำ (ย้ายห้อง) — ใช้แถวแรกของแต่ละรหัส
  const seen = new Set();
  const students = [];
  for (const r of dorm) {
    const id = String(r.STUDENTID);
    if (seen.has(id)) continue;
    seen.add(id);
    const info = regById.get(id) || {};
    students.push({
      externalStudentId: id,
      studentCode: id,
      name: info.NAME_TH || `นักศึกษา ${id}`,
      nameEn: info.NAME_EN || null,
      photoUrl: info.PHOTO_URL || null,
      dormitory: String(r.BUILDNAME || ''),
      dormitoryEn: String(r.BUILDNAME_ENG || ''),
      roomNumber: String(r.DOMNUMBER || ''),
      status: r.STUDENTSTATUS === 10 ? 'ACTIVE' : 'MOVED_OUT',
    });
  }
  await p.student.createMany({ data: students });
  console.log(`students: ${students.length} คน`);

  // ── 3. access_logs ────────────────────────────────────────────
  const dbStudents = await p.student.findMany({ select: { id: true, studentCode: true } });
  const idByCode = new Map(dbStudents.map((s) => [s.studentCode, s.id]));

  // รูป placeholder หน้าคน — คงที่ต่อ นศ. (คนเดิมสแกนกี่ครั้งก็หน้าเดิม)
  const codes = [...new Set(att.map((r) => String(r['User ID'])))];
  const faceOf = new Map(codes.map((c, i) => [c, `https://i.pravatar.cc/150?img=${(i % 70) + 1}`]));

  let logs = 0, skipped = 0;
  for (const r of att) {
    const code = String(r['User ID']);
    const studentId = idByCode.get(code);
    if (!studentId || !/^[0-9]{10}$/.test(code)) { skipped++; continue; } // รปภ./บุคคลอื่น
    const accessTime = new Date(String(r.Timestamp).replace(' ', 'T') + '+07:00');
    await p.accessLog.upsert({
      where: { unique_access_event: { studentId, accessTime, type: 'IN' } },
      create: {
        studentId,
        accessTime,
        type: 'IN',
        gateName: String(r.Location || GATE_TH),
        gateNameEn: GATE_EN,
        photoUrl: faceOf.get(code),
        scanPhotoUrl: faceOf.get(code),
      },
      update: {},
    });
    logs++;
  }
  console.log(`access_logs: ${logs} แถว (ข้ามแถวที่ไม่ใช่ นศ. ${skipped} แถว)`);

  // ── 4. ผูกผู้ปกครอง ───────────────────────────────────────────
  // สุ่มจาก นศ. ที่มี log (login มาแล้วเห็นประวัติจริง) — deterministic
  const withLogs = codes.filter((c) => idByCode.has(c));
  const rand = rng(20260707);
  const pool = [...withLogs].sort(() => rand() - 0.5);
  let cursor = 0;
  for (const parent of PARENT_IDS) {
    for (let i = 0; i < parent.children && cursor < pool.length; i++, cursor++) {
      const code = pool[cursor];
      await p.parentStudentRegistry.create({
        data: {
          parentCitizenId: parent.citizenId,
          studentId: idByCode.get(code),
          relationship: parent.relationship,
        },
      });
      const info = regById.get(code) || {};
      console.log(`ผูก: ${parent.citizenId} (${parent.relationship}) -> ${code} ${info.NAME_TH || ''}`);
    }
  }

  await p.$disconnect();
  console.log('เสร็จสิ้น');
}

main().catch((e) => { console.error(e); process.exit(1); });
