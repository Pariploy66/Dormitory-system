/**
 * make-registrar.js — สร้าง "ไฟล์ฝ่ายทะเบียน (mockup)" data/registrar_students.xlsx
 *
 * แนวคิด: ระบบ engage รู้แค่ "ใครพักห้องไหน + ใครสแกนเข้า" (data/mockup_engage.xlsx)
 * ส่วน "ชื่อ-ตัวตนนักศึกษา" เป็นข้อมูลของฝ่ายทะเบียน — ไฟล์นี้จำลองข้อมูลชุดนั้น
 * โดยยึดรหัสนักศึกษาจาก sheet DORM แล้ว:
 *   - 23 คนที่มี log ใน Attendance IN → ใช้ชื่อจริงจากไฟล์ + ชื่ออังกฤษถอดเสียง
 *   - ที่เหลือ → สุ่มชื่อไทย/จีนถอดเสียงแบบสมจริง (สุ่มแบบ deterministic — รันซ้ำได้ชื่อเดิม)
 *
 * วิธีใช้:  node scripts/make-registrar.js
 * ผลลัพธ์: data/registrar_students.xlsx (STUDENTID | NAME_TH | NAME_EN | PHOTO_URL)
 */
const path = require('path');
const XLSX = require('xlsx');

const DATA_DIR = path.join(__dirname, '..', 'data');
const ENGAGE_FILE = path.join(DATA_DIR, 'mockup_engage.xlsx');
const OUT_FILE = path.join(DATA_DIR, 'registrar_students.xlsx');

// ── ชื่อจริงจาก Attendance IN + คำถอดเสียงอังกฤษ ─────────────────────────────
const KNOWN_NAMES = {
  '6632718057': ['หวังเฮ่อตี้', 'Wang Hedi'],
  '6633315067': ['หยางหยาง', 'Yang Yang'],
  '6533412057': ['หวังฉู่หรัน', 'Wang Churan'],
  '6433112453': ['หวังซิงเยว่', 'Wang Xingyue'],
  '6632714510': ['เฉิน เจ๋อหย่วน', 'Chen Zheyuan'],
  '6432716110': ['ตี้เร่อปา', 'Dilraba'],
  '6633812034': ['น้ำไม่ไหล ไฟไม่มา', 'Nam Mailai Faimaima'],
  '6532817091': ['ฝนตก ตามฤดู', 'Fontok Tamruedu'],
  '6532817079': ['พิซซ่า หน้าตลาด', 'Pizza Natalad'],
  '6632714529': ['ติ้งหวัง', 'Ding Wang'],
  '6532817089': ['ฝนตก ตามฤดู', 'Fontok Tamruedu'],
  '6632716037': ['จางหลิงเฮ่อ', 'Zhang Linghe'],
  '6332517021': ['ต้วน เจียซวี่', 'Duan Jiaxu'],
  '6632713079': ['หวงจิ่งอวี๋', 'Huang Jingyu'],
  '6632517120': ['ไป๋ลู่', 'Bai Lu'],
  '6633013031': ['จ้าวลู่ซือ', 'Zhao Lusi'],
  '6633014028': ['ไป๋จิ้งถิง', 'Bai Jingting'],
  '6633913033': ['หลินอี', 'Lin Yi'],
  '6633915034': ['เฉิอเข่อจิง', 'Chen Kejing'],
  '6432721020': ['Jackson ma', 'Jackson Ma'],
  '6633915115': ['จางรั่วหนาน', 'Zhang Ruonan'],
  '6633915074': ['จวีจิ้งอี', 'Ju Jingyi'],
  '6632712138': ['นายกรัฐมนตรี', 'Nayok Ratthamontri'],
};

// ── คลังชื่อสำหรับ generate (ไทย + จีนถอดเสียง แบบ มฟล. จริง) ────────────────
const TH_FIRST = [
  ['กัญญาณัฐ', 'Kanyanat'], ['ณัฐภัทร', 'Natthaphat'], ['พิมพ์ชนก', 'Pimchanok'],
  ['ธนกฤต', 'Thanakrit'], ['ศศิกานต์', 'Sasikan'], ['ภูริณัฐ', 'Phurinat'],
  ['อริสรา', 'Arisara'], ['จิรายุ', 'Jirayu'], ['นภัสสร', 'Napatsorn'],
  ['กิตติพศ', 'Kittiphot'], ['วริศรา', 'Waritsara'], ['ปุณณวิช', 'Punnawich'],
  ['ชาลิสา', 'Chalisa'], ['ศุภกร', 'Supakorn'], ['ณิชาภัทร', 'Nichaphat'],
  ['พชร', 'Phachara'], ['ธมลวรรณ', 'Thamonwan'], ['รัชชานนท์', 'Ratchanon'],
  ['สุพิชญา', 'Supichaya'], ['เตชินท์', 'Techin'],
];
const TH_LAST = [
  ['ใจดี', 'Jaidee'], ['สุขสวัสดิ์', 'Suksawat'], ['วงศ์ษา', 'Wongsa'],
  ['แก้วมณี', 'Kaewmanee'], ['ศรีสุวรรณ', 'Srisuwan'], ['บุญมาก', 'Boonmak'],
  ['พรมมา', 'Promma'], ['คำแสน', 'Khamsaen'], ['อินทร์ตา', 'Inta'],
  ['ธรรมโชติ', 'Thammachot'], ['เชียงแขก', 'Chiangkhaek'], ['นามวงศ์', 'Namwong'],
  ['ปัญญาดี', 'Panyadee'], ['มูลใจ', 'Moonjai'], ['ทาคำ', 'Thakham'],
];
const CN_NAMES = [
  ['หลี่เจียหมิง', 'Li Jiaming'], ['หวังอี้ห่าน', 'Wang Yihan'],
  ['เฉินซือหยู', 'Chen Siyu'], ['หลิวหย่าถิง', 'Liu Yating'],
  ['จางเหวินเจี๋ย', 'Zhang Wenjie'], ['หลินเสี่ยวหมิ่น', 'Lin Xiaomin'],
  ['โจวจื่อฮ่าว', 'Zhou Zihao'], ['สวี่จิงอี้', 'Xu Jingyi'],
  ['เกาเทียนอวี่', 'Gao Tianyu'], ['เหอเหม่ยหลิง', 'He Meiling'],
];

// deterministic RNG (mulberry32) — รันกี่ครั้งก็ได้ชื่อชุดเดิม
function rng(seed) {
  return function () {
    seed |= 0; seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function main() {
  const wb = XLSX.readFile(ENGAGE_FILE);
  const dorm = XLSX.utils.sheet_to_json(wb.Sheets['DORM'], { defval: '' });
  const ids = [...new Set(dorm.map((r) => String(r.STUDENTID)))];

  const rand = rng(20260707);
  const usedNames = new Set(Object.values(KNOWN_NAMES).map(([th]) => th));

  const rows = ids.map((id) => {
    let th, en;
    if (KNOWN_NAMES[id]) {
      [th, en] = KNOWN_NAMES[id];
    } else {
      // ~30% ชื่อจีนถอดเสียง (นศ.จีนเยอะแบบ มฟล.) / 70% ชื่อไทย
      do {
        if (rand() < 0.3) {
          [th, en] = CN_NAMES[Math.floor(rand() * CN_NAMES.length)];
        } else {
          const f = TH_FIRST[Math.floor(rand() * TH_FIRST.length)];
          const l = TH_LAST[Math.floor(rand() * TH_LAST.length)];
          th = `${f[0]} ${l[0]}`;
          en = `${f[1]} ${l[1]}`;
        }
      } while (usedNames.has(th));
      usedNames.add(th);
    }
    return {
      STUDENTID: id,
      NAME_TH: th,
      NAME_EN: en,
      PHOTO_URL: `https://api.dicebear.com/9.x/adventurer/png?size=150&seed=${id}`,
    };
  });

  const ws = XLSX.utils.json_to_sheet(rows);
  const out = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(out, ws, 'REGISTRAR');
  XLSX.writeFile(out, OUT_FILE);
  console.log(`สร้าง ${OUT_FILE}`);
  console.log(`นักศึกษา ${rows.length} คน (ชื่อจริงจาก Attendance ${Object.keys(KNOWN_NAMES).length} คน, generate ${rows.length - new Set(Object.keys(KNOWN_NAMES).filter((k) => ids.includes(k))).size} คน)`);
}

main();
