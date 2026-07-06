/**
 * import-registry.js — อ่านไฟล์ Excel จากฝ่ายทะเบียน แล้วยิงเข้า
 * POST /internal/registry/sync ให้อัตโนมัติ
 *
 * วิธีใช้:
 *   node scripts/import-registry.js <ไฟล์.xlsx>            → อ่าน + ยิงเข้า backend
 *   node scripts/import-registry.js <ไฟล์.xlsx> --dry-run   → แค่พิมพ์ JSON ออกมาดู ไม่ยิงจริง
 *
 * ต้องรัน backend ไว้ก่อน (npm run start:dev) และมี .env ที่มี INTERNAL_API_KEY
 *
 * รูปแบบคอลัมน์ใน Excel (แถวแรกเป็นหัวตาราง ใช้ชื่อไทยหรืออังกฤษก็ได้):
 *   รหัสนักศึกษา | ชื่อ-สกุล | รหัสภายนอก | หอพัก | ห้อง | รูป | สถานะ | เลขบัตรผู้ปกครอง | ความสัมพันธ์
 *   studentCode  | name     | externalId | dorm | room | photo | status | parentCitizenId | relationship
 *
 * - นศ. 1 คนมีผู้ปกครองหลายคน → ใส่หลายแถว รหัสนักศึกษาซ้ำกันได้ (สคริปต์รวมให้เอง)
 * - คอลัมน์ไหนไม่มีก็ข้ามได้ ยกเว้น รหัสนักศึกษา + ชื่อ
 * - ความสัมพันธ์: พ่อ/FATHER, แม่/MOTHER, ผู้ปกครอง/GUARDIAN (ไม่ใส่ = GUARDIAN)
 * - สถานะ: ACTIVE (ไม่ใส่ = ACTIVE) / GRADUATED / MOVED_OUT
 */
require('dotenv').config();
const path = require('path');
const XLSX = require('xlsx');

const BASE_URL = process.env.SYNC_BASE_URL || 'http://localhost:3000';

// ── ชื่อหัวคอลัมน์ที่ยอมรับ (ไทย/อังกฤษ) ─────────────────────────────
const COL = {
  studentCode: ['รหัสนักศึกษา', 'รหัสนศ', 'studentcode', 'student_code', 'รหัส'],
  name: ['ชื่อ-สกุล', 'ชื่อสกุล', 'ชื่อ', 'name'],
  externalId: ['รหัสภายนอก', 'externalid', 'external_student_id', 'externalstudentid'],
  dormitory: ['หอพัก', 'หอ', 'dorm', 'dormitory'],
  roomNumber: ['ห้อง', 'เลขห้อง', 'room', 'roomnumber', 'room_number'],
  photoUrl: ['รูป', 'รูปภาพ', 'photo', 'photourl', 'photo_url'],
  status: ['สถานะ', 'status'],
  parentCitizenId: ['เลขบัตรผู้ปกครอง', 'เลขบัตรประชาชนผู้ปกครอง', 'parentcitizenid', 'parent_citizen_id', 'pid'],
  relationship: ['ความสัมพันธ์', 'relationship'],
};

const REL_MAP = {
  'พ่อ': 'FATHER', 'บิดา': 'FATHER', 'father': 'FATHER',
  'แม่': 'MOTHER', 'มารดา': 'MOTHER', 'mother': 'MOTHER',
  'ผู้ปกครอง': 'GUARDIAN', 'guardian': 'GUARDIAN',
  'อื่นๆ': 'OTHER', 'other': 'OTHER',
};

function pick(row, keys) {
  for (const rawKey of Object.keys(row)) {
    const k = rawKey.trim().toLowerCase().replace(/\s+/g, '');
    if (keys.some((want) => k === want.toLowerCase().replace(/\s+/g, ''))) {
      const v = row[rawKey];
      return v == null ? '' : String(v).trim();
    }
  }
  return '';
}

function main() {
  const [file, flag] = process.argv.slice(2);
  if (!file) {
    console.error('ใช้: node scripts/import-registry.js <ไฟล์.xlsx> [--dry-run]');
    process.exit(1);
  }

  const wb = XLSX.readFile(path.resolve(file));
  const rows = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]], { defval: '' });
  if (!rows.length) {
    console.error('ไม่พบข้อมูลในชีตแรกของไฟล์');
    process.exit(1);
  }

  const studentsByCode = new Map();
  const guardians = [];

  for (const row of rows) {
    const studentCode = pick(row, COL.studentCode);
    const name = pick(row, COL.name);
    if (!studentCode || !name) continue; // ข้ามแถวว่าง/แถวรวมยอด

    if (!studentsByCode.has(studentCode)) {
      const statusRaw = pick(row, COL.status).toUpperCase();
      studentsByCode.set(studentCode, {
        externalStudentId: pick(row, COL.externalId) || studentCode,
        studentCode,
        name,
        photoUrl: pick(row, COL.photoUrl) || undefined,
        dormitory: pick(row, COL.dormitory) || undefined,
        roomNumber: pick(row, COL.roomNumber) || undefined,
        status: ['ACTIVE', 'GRADUATED', 'MOVED_OUT'].includes(statusRaw)
          ? statusRaw
          : 'ACTIVE',
      });
    }

    const pid = pick(row, COL.parentCitizenId).replace(/[^0-9]/g, '');
    if (pid) {
      const relRaw = pick(row, COL.relationship).toLowerCase();
      guardians.push({
        parentCitizenId: pid,
        studentCode,
        relationship: REL_MAP[relRaw] || 'GUARDIAN',
      });
    }
  }

  const payload = { students: [...studentsByCode.values()], guardians };
  console.log(`อ่านได้: นักศึกษา ${payload.students.length} คน, คู่ผู้ปกครอง ${payload.guardians.length} คู่`);

  if (flag === '--dry-run') {
    console.log(JSON.stringify(payload, null, 2));
    return;
  }

  fetch(`${BASE_URL}/internal/registry/sync`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Internal-API-Key': process.env.INTERNAL_API_KEY || '',
    },
    body: JSON.stringify(payload),
  })
    .then(async (r) => {
      console.log('HTTP', r.status, await r.text());
      if (!r.ok) process.exit(1);
    })
    .catch((e) => {
      console.error('ยิงไม่สำเร็จ (backend รันอยู่ไหม?):', e.message);
      process.exit(1);
    });
}

main();
