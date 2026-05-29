"""
สร้าง PDF คู่มือการใช้งาน MFU Dormitory App
"""
import os
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import cm
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    HRFlowable, PageBreak, KeepTogether,
)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus.doctemplate import PageTemplate, BaseDocTemplate, Frame

# ── Fonts ────────────────────────────────────────────────────────────────────
pdfmetrics.registerFont(TTFont("Tahoma",   r"C:\Windows\Fonts\tahoma.ttf"))
pdfmetrics.registerFont(TTFont("TahomaBd", r"C:\Windows\Fonts\tahomabd.ttf"))

# ── Colors ────────────────────────────────────────────────────────────────────
MFU_RED   = colors.HexColor("#D61A22")
MFU_DARK  = colors.HexColor("#A31219")
GRAY_LIGHT= colors.HexColor("#F5F5F5")
GRAY_MID  = colors.HexColor("#DDDDDD")
GRAY_TEXT = colors.HexColor("#666666")
WHITE     = colors.white
BLACK     = colors.HexColor("#1A1A1A")

# ── Styles ───────────────────────────────────────────────────────────────────
def make_styles():
    cover_title = ParagraphStyle(
        "CoverTitle", fontName="TahomaBd", fontSize=28,
        textColor=WHITE, leading=36, spaceAfter=8,
    )
    cover_sub = ParagraphStyle(
        "CoverSub", fontName="Tahoma", fontSize=13,
        textColor=colors.HexColor("#FFCCCC"), leading=18, spaceAfter=4,
    )
    cover_univ = ParagraphStyle(
        "CoverUniv", fontName="Tahoma", fontSize=11,
        textColor=colors.HexColor("#FFAAAA"), leading=16,
    )
    h1 = ParagraphStyle(
        "H1", fontName="TahomaBd", fontSize=16,
        textColor=MFU_RED, leading=22, spaceBefore=18, spaceAfter=8,
    )
    h2 = ParagraphStyle(
        "H2", fontName="TahomaBd", fontSize=13,
        textColor=BLACK, leading=18, spaceBefore=12, spaceAfter=6,
    )
    body = ParagraphStyle(
        "Body", fontName="Tahoma", fontSize=11,
        textColor=BLACK, leading=17, spaceAfter=4,
    )
    body_small = ParagraphStyle(
        "BodySmall", fontName="Tahoma", fontSize=10,
        textColor=GRAY_TEXT, leading=15, spaceAfter=3,
    )
    note = ParagraphStyle(
        "Note", fontName="Tahoma", fontSize=10,
        textColor=colors.HexColor("#8B4000"),
        backColor=colors.HexColor("#FFF8E1"),
        leading=15, spaceAfter=6,
        leftIndent=8, rightIndent=8,
        borderPadding=(6, 8, 6, 8),
    )
    bullet = ParagraphStyle(
        "Bullet", fontName="Tahoma", fontSize=11,
        textColor=BLACK, leading=17, spaceAfter=3,
        leftIndent=16, bulletIndent=4,
    )
    footer_style = ParagraphStyle(
        "Footer", fontName="Tahoma", fontSize=9,
        textColor=GRAY_TEXT, leading=14, alignment=1,
    )
    return {
        "cover_title": cover_title, "cover_sub": cover_sub,
        "cover_univ": cover_univ, "h1": h1, "h2": h2,
        "body": body, "body_small": body_small,
        "note": note, "bullet": bullet, "footer": footer_style,
    }

S = make_styles()

# ── Helpers ───────────────────────────────────────────────────────────────────
def hr(color=GRAY_MID, thickness=0.5):
    return HRFlowable(width="100%", thickness=thickness, color=color,
                      spaceAfter=6, spaceBefore=6)

def h1(text): return Paragraph(text, S["h1"])
def h2(text): return Paragraph(text, S["h2"])
def body(text): return Paragraph(text, S["body"])
def note(text): return Paragraph(f"<b>หมายเหตุ:</b> {text}", S["note"])
def bullet(text): return Paragraph(f"• {text}", S["bullet"])
def sp(h=8): return Spacer(1, h)

def section_header(text):
    """Red background section header"""
    t = Table([[Paragraph(text, ParagraphStyle(
        "SH", fontName="TahomaBd", fontSize=14,
        textColor=WHITE, leading=20,
    ))]], colWidths=[16*cm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (-1,-1), MFU_RED),
        ("TOPPADDING",    (0,0), (-1,-1), 8),
        ("BOTTOMPADDING", (0,0), (-1,-1), 8),
        ("LEFTPADDING",   (0,0), (-1,-1), 12),
        ("RIGHTPADDING",  (0,0), (-1,-1), 12),
        ("ROWBACKGROUNDS",(0,0), (-1,-1), [MFU_RED]),
    ]))
    return t

def info_table(rows, col_widths=None):
    """Styled 2-column table for feature descriptions"""
    if col_widths is None:
        col_widths = [5*cm, 11*cm]
    data = []
    for label, val in rows:
        data.append([
            Paragraph(f"<b>{label}</b>", S["body"]),
            Paragraph(val, S["body"]),
        ])
    t = Table(data, colWidths=col_widths)
    t.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (0,-1), GRAY_LIGHT),
        ("GRID",          (0,0), (-1,-1), 0.5, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 6),
        ("BOTTOMPADDING", (0,0), (-1,-1), 6),
        ("LEFTPADDING",   (0,0), (-1,-1), 8),
        ("RIGHTPADDING",  (0,0), (-1,-1), 8),
        ("VALIGN",        (0,0), (-1,-1), "TOP"),
    ]))
    return t

def log_example_table(rows):
    """Styled table for log examples"""
    data = [
        [
            Paragraph("<b>สัญลักษณ์</b>", S["body_small"]),
            Paragraph("<b>ความหมาย</b>", S["body_small"]),
        ]
    ]
    for sym, meaning in rows:
        data.append([
            Paragraph(sym, S["body_small"]),
            Paragraph(meaning, S["body_small"]),
        ])
    t = Table(data, colWidths=[5*cm, 11*cm])
    t.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,0), MFU_DARK),
        ("TEXTCOLOR",     (0,0), (-1,0), WHITE),
        ("BACKGROUND",    (0,1), (-1,-1), WHITE),
        ("ROWBACKGROUNDS",(0,1), (-1,-1), [WHITE, GRAY_LIGHT]),
        ("GRID",          (0,0), (-1,-1), 0.5, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 6),
        ("BOTTOMPADDING", (0,0), (-1,-1), 6),
        ("LEFTPADDING",   (0,0), (-1,-1), 8),
        ("RIGHTPADDING",  (0,0), (-1,-1), 8),
        ("VALIGN",        (0,0), (-1,-1), "MIDDLE"),
    ]))
    return t

# ── Page template with header/footer ─────────────────────────────────────────
PAGE_W, PAGE_H = A4

class MfuDocTemplate(BaseDocTemplate):
    def __init__(self, filename, **kwargs):
        super().__init__(filename, **kwargs)
        frame = Frame(
            1.8*cm, 2.0*cm,
            PAGE_W - 3.6*cm, PAGE_H - 3.5*cm,
            id="main",
        )
        template = PageTemplate(
            id="main",
            frames=[frame],
            onPage=self._draw_chrome,
        )
        self.addPageTemplates([template])
        self._page_num = 0

    def _draw_chrome(self, canvas, doc):
        canvas.saveState()
        page_num = doc.page

        # Header bar (skip page 1 = cover)
        if page_num > 1:
            canvas.setFillColor(MFU_RED)
            canvas.rect(0, PAGE_H - 1.5*cm, PAGE_W, 1.5*cm, fill=1, stroke=0)
            canvas.setFillColor(WHITE)
            canvas.setFont("TahomaBd", 10)
            canvas.drawString(1.8*cm, PAGE_H - 1.0*cm, "MFU Dormitory")
            canvas.setFont("Tahoma", 9)
            canvas.drawRightString(
                PAGE_W - 1.8*cm, PAGE_H - 1.0*cm,
                "คู่มือการใช้งานสำหรับผู้ปกครอง",
            )

        # Footer
        if page_num > 1:
            canvas.setFillColor(GRAY_MID)
            canvas.rect(0, 0, PAGE_W, 1.8*cm, fill=1, stroke=0)
            canvas.setFillColor(GRAY_TEXT)
            canvas.setFont("Tahoma", 8)
            canvas.drawString(1.8*cm, 0.7*cm,
                "© Mae Fah Luang University  |  สำหรับผู้ปกครองเท่านั้น")
            canvas.drawRightString(
                PAGE_W - 1.8*cm, 0.7*cm, f"หน้า {page_num - 1}")

        canvas.restoreState()

# ── Cover page ────────────────────────────────────────────────────────────────
def cover_page():
    """Returns flowables for the cover page"""
    items = []

    # Red full-width banner (simulated with a table)
    banner_data = [[
        Paragraph(
            "MFU Dormitory",
            ParagraphStyle("BT", fontName="TahomaBd", fontSize=36,
                           textColor=WHITE, leading=44),
        )
    ]]
    banner = Table(banner_data, colWidths=[16*cm], rowHeights=[3.5*cm])
    banner.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,-1), MFU_RED),
        ("ALIGN",         (0,0), (-1,-1), "CENTER"),
        ("VALIGN",        (0,0), (-1,-1), "MIDDLE"),
        ("TOPPADDING",    (0,0), (-1,-1), 20),
        ("BOTTOMPADDING", (0,0), (-1,-1), 20),
    ]))

    items.append(sp(40))
    items.append(banner)
    items.append(sp(20))

    items.append(Paragraph(
        "คู่มือการใช้งาน",
        ParagraphStyle("CT2", fontName="TahomaBd", fontSize=22,
                       textColor=MFU_RED, leading=28, alignment=1),
    ))
    items.append(sp(8))
    items.append(Paragraph(
        "สำหรับผู้ปกครองนักศึกษาหอพัก",
        ParagraphStyle("CT3", fontName="Tahoma", fontSize=14,
                       textColor=GRAY_TEXT, leading=20, alignment=1),
    ))
    items.append(sp(6))
    items.append(Paragraph(
        "Mae Fah Luang University",
        ParagraphStyle("CT4", fontName="Tahoma", fontSize=12,
                       textColor=GRAY_TEXT, leading=18, alignment=1),
    ))
    items.append(sp(60))

    # Info box
    info = Table([
        [Paragraph("ระบบติดตามการเข้า-ออกหอพักแบบ Real-time",
                   ParagraphStyle("IB", fontName="TahomaBd", fontSize=12,
                                  textColor=MFU_DARK, leading=18))],
        [Paragraph("แอปพลิเคชันสำหรับผู้ปกครองรับทราบสถานการณ์ของบุตรหลาน"
                   "ในหอพักมหาวิทยาลัยแม่ฟ้าหลวงได้ทุกที่ทุกเวลา",
                   ParagraphStyle("IB2", fontName="Tahoma", fontSize=11,
                                  textColor=BLACK, leading=17))],
    ], colWidths=[16*cm])
    info.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,-1), colors.HexColor("#FFF0F0")),
        ("BOX",           (0,0), (-1,-1), 1.5, MFU_RED),
        ("TOPPADDING",    (0,0), (-1,-1), 10),
        ("BOTTOMPADDING", (0,0), (-1,-1), 10),
        ("LEFTPADDING",   (0,0), (-1,-1), 16),
        ("RIGHTPADDING",  (0,0), (-1,-1), 16),
    ]))
    items.append(info)
    items.append(PageBreak())
    return items

# ── Build story ───────────────────────────────────────────────────────────────
def build_story():
    story = []
    story += cover_page()

    # ── Section 1: แอปนี้คืออะไร ──────────────────────────────────────────
    story.append(section_header("1.  แอปนี้คืออะไร?"))
    story.append(sp(10))
    story.append(body(
        "MFU Dormitory คือแอปพลิเคชันสำหรับ <b>ผู้ปกครอง</b> ของนักศึกษาหอพัก "
        "มหาวิทยาลัยแม่ฟ้าหลวง ช่วยให้ผู้ปกครองสามารถ "
        "<b>ติดตามการเข้า-ออกหอพักของบุตรหลานได้แบบ Real-time</b> "
        "ผ่านสมาร์ทโฟน โดยระบบจะอัปเดตข้อมูลอัตโนมัติทุก 30 วินาที "
        "และส่งการแจ้งเตือนทันทีเมื่อบุตรหลานรูดบัตรที่ประตูหอพัก"
    ))
    story.append(sp(8))

    features = Table([
        [Paragraph("Real-time", S["body"]),
         Paragraph("ข้อมูลอัปเดตอัตโนมัติทุก 30 วินาที", S["body"])],
        [Paragraph("Push Notification", S["body"]),
         Paragraph("แจ้งเตือนทันทีเมื่อบุตรหลานเข้า-ออกหอพัก", S["body"])],
        [Paragraph("ประวัติย้อนหลัง", S["body"]),
         Paragraph("ดูประวัติได้สูงสุด 7 วัน พร้อมระบบกรอง", S["body"])],
        [Paragraph("Bilingual", S["body"]),
         Paragraph("รองรับภาษาไทยและอังกฤษ สลับได้ทันที", S["body"])],
    ], colWidths=[5*cm, 11*cm])
    features.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,-1), WHITE),
        ("BACKGROUND",    (0,0), (0,-1), GRAY_LIGHT),
        ("GRID",          (0,0), (-1,-1), 0.5, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 7),
        ("BOTTOMPADDING", (0,0), (-1,-1), 7),
        ("LEFTPADDING",   (0,0), (-1,-1), 10),
        ("RIGHTPADDING",  (0,0), (-1,-1), 10),
        ("FONTNAME",      (0,0), (0,-1), "TahomaBd"),
        ("TEXTCOLOR",     (0,0), (0,-1), MFU_RED),
    ]))
    story.append(features)
    story.append(sp(16))

    # ── Section 2: หน้าเข้าสู่ระบบ ───────────────────────────────────────
    story.append(section_header("2.  หน้าเข้าสู่ระบบ (Login)"))
    story.append(sp(10))
    story.append(body(
        "เมื่อเปิดแอปครั้งแรก จะพบกับหน้า Login "
        "ที่แสดงโลโก้มหาวิทยาลัยแม่ฟ้าหลวงพร้อมช่องกรอกข้อมูล"
    ))
    story.append(sp(8))

    story.append(h2("องค์ประกอบในหน้า Login"))
    login_rows = [
        ("TH / EN  (มุมบนซ้าย)", "สลับภาษาไทย/อังกฤษ — แอปเปลี่ยนทั้งระบบทันที"),
        ("ช่อง Email",            "กรอกอีเมลที่ลงทะเบียนไว้กับระบบหอพัก"),
        ("ช่อง Password",         "กรอกรหัสผ่าน กดไอคอนรูปตาเพื่อดู/ซ่อนรหัสผ่าน"),
        ("ปุ่ม Login with Thai ID","กดเพื่อเข้าสู่ระบบด้วย Email + Password"),
        ("ลิงก์ Register",        "กดเพื่อไปหน้าสมัครสมาชิก (สำหรับผู้ปกครองใหม่)"),
    ]
    story.append(info_table(login_rows))
    story.append(sp(10))
    story.append(note(
        "บัญชีต้องถูกเชื่อมกับข้อมูลนักศึกษาโดยเจ้าหน้าที่หอพักก่อน "
        "จึงจะเห็นข้อมูลบุตรหลานได้ หากยังไม่ได้เชื่อม กรุณาติดต่อเจ้าหน้าที่"
    ))
    story.append(sp(16))

    # ── Section 3: แถบนำทาง ───────────────────────────────────────────────
    story.append(section_header("3.  แถบนำทางหลัก (Bottom Navigation)"))
    story.append(sp(10))
    story.append(body("หลัง Login สำเร็จ จะมี 3 แท็บที่แถบด้านล่างของหน้าจอ:"))
    story.append(sp(8))

    nav = Table([
        [Paragraph("<b>แท็บ</b>", S["body"]),
         Paragraph("<b>ชื่อ</b>", S["body"]),
         Paragraph("<b>หน้าที่</b>", S["body"])],
        [Paragraph("[1]  หน้าหลัก", S["body"]),
         Paragraph("Dashboard", S["body"]),
         Paragraph("ดูสถานะปัจจุบันและกิจกรรมล่าสุดของบุตรหลาน", S["body"])],
        [Paragraph("[2]  ประวัติ", S["body"]),
         Paragraph("History", S["body"]),
         Paragraph("ดูประวัติการเข้า-ออกหอพักย้อนหลังพร้อมระบบกรอง", S["body"])],
        [Paragraph("[3]  ตั้งค่า", S["body"]),
         Paragraph("Setting", S["body"]),
         Paragraph("ตั้งค่าภาษา ดูข้อมูลบัญชี และออกจากระบบ", S["body"])],
    ], colWidths=[4*cm, 3.5*cm, 8.5*cm])
    nav.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,0), MFU_DARK),
        ("TEXTCOLOR",     (0,0), (-1,0), WHITE),
        ("FONTNAME",      (0,0), (-1,0), "TahomaBd"),
        ("BACKGROUND",    (0,1), (-1,-1), WHITE),
        ("ROWBACKGROUNDS",(0,1), (-1,-1), [WHITE, GRAY_LIGHT]),
        ("GRID",          (0,0), (-1,-1), 0.5, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 7),
        ("BOTTOMPADDING", (0,0), (-1,-1), 7),
        ("LEFTPADDING",   (0,0), (-1,-1), 10),
        ("RIGHTPADDING",  (0,0), (-1,-1), 10),
        ("VALIGN",        (0,0), (-1,-1), "MIDDLE"),
    ]))
    story.append(nav)
    story.append(sp(16))

    # ── Section 4: Dashboard ──────────────────────────────────────────────
    story.append(section_header("4.  แท็บ Dashboard (หน้าหลัก)"))
    story.append(sp(10))
    story.append(body(
        "หน้าหลักแสดงข้อมูลสดแบบ Real-time "
        "อัปเดตอัตโนมัติทุก <b>30 วินาที</b> โดยไม่ต้องกด Refresh"
    ))
    story.append(sp(10))

    # Sub-sections
    subs = [
        ("การ์ดข้อมูลนักศึกษา", [
            "ชื่อ-นามสกุล ของบุตรหลาน",
            "รหัสนักศึกษา",
            "ชื่อหอพักและเลขห้อง  เช่น หอ A ห้อง 101",
        ]),
        ("สถานะปัจจุบัน (Current Status)", [
            "[อยู่ในหอพัก]  — เข้ามาแล้ว ยังไม่ออก",
            "[อยู่นอกหอพัก] — ออกไปแล้ว ยังไม่กลับ",
            "Badge LIVE สีเขียวกะพริบ = ข้อมูลสดจากระบบ ณ ขณะนั้น",
        ]),
        ("สรุปวันนี้", [
            "จำนวนครั้งที่เข้าหอพักในวันนี้",
            "จำนวนครั้งที่ออกจากหอพักในวันนี้",
        ]),
        ("กิจกรรมล่าสุด (Recent Activity)", [
            "แสดง log ล่าสุด 1 รายการ พร้อมชื่อประตูและเวลา",
            "สถานะ: ตรงเวลา หรือ สาย",
            "กด 'ดูประวัติทั้งหมด' เพื่อไปแท็บ History อัตโนมัติ",
        ]),
    ]
    for title, bullets in subs:
        story.append(KeepTogether([
            h2(title),
            *[bullet(b) for b in bullets],
            sp(6),
        ]))

    story.append(sp(8))

    # ── Section 5: History ────────────────────────────────────────────────
    story.append(section_header("5.  แท็บ History (ประวัติ)"))
    story.append(sp(10))
    story.append(body(
        "แสดงประวัติการเข้า-ออกหอพักทั้งหมด สามารถกรองข้อมูล "
        "ได้ตามช่วงเวลาและประเภทการเข้า-ออก"
    ))
    story.append(sp(10))

    story.append(h2("กรองตามช่วงเวลา"))
    filter_time = Table([
        [Paragraph("<b>ปุ่ม</b>", S["body"]),
         Paragraph("<b>ข้อมูลที่แสดง</b>", S["body"])],
        [Paragraph("วันนี้ (Today)", S["body"]),
         Paragraph("เฉพาะวันนี้เท่านั้น", S["body"])],
        [Paragraph("3 วันล่าสุด", S["body"]),
         Paragraph("ย้อนหลัง 3 วัน นับจากวันนี้", S["body"])],
        [Paragraph("7 วันล่าสุด", S["body"]),
         Paragraph("ย้อนหลัง 7 วัน นับจากวันนี้", S["body"])],
    ], colWidths=[5*cm, 11*cm])
    filter_time.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,0), MFU_DARK),
        ("TEXTCOLOR",     (0,0), (-1,0), WHITE),
        ("FONTNAME",      (0,0), (-1,0), "TahomaBd"),
        ("ROWBACKGROUNDS",(0,1), (-1,-1), [WHITE, GRAY_LIGHT]),
        ("GRID",          (0,0), (-1,-1), 0.5, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 7),
        ("BOTTOMPADDING", (0,0), (-1,-1), 7),
        ("LEFTPADDING",   (0,0), (-1,-1), 10),
        ("RIGHTPADDING",  (0,0), (-1,-1), 10),
    ]))
    story.append(filter_time)
    story.append(sp(10))

    story.append(h2("กรองตามประเภท"))
    filter_type = Table([
        [Paragraph("<b>ปุ่ม</b>", S["body"]),
         Paragraph("<b>ข้อมูลที่แสดง</b>", S["body"])],
        [Paragraph("ทั้งหมด", S["body"]),
         Paragraph("แสดงทั้งการเข้าและการออก", S["body"])],
        [Paragraph("เข้า (Entry)", S["body"]),
         Paragraph("เฉพาะครั้งที่เข้าหอพัก", S["body"])],
        [Paragraph("ออก (Exit)", S["body"]),
         Paragraph("เฉพาะครั้งที่ออกจากหอพัก", S["body"])],
    ], colWidths=[5*cm, 11*cm])
    filter_type.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,0), MFU_DARK),
        ("TEXTCOLOR",     (0,0), (-1,0), WHITE),
        ("FONTNAME",      (0,0), (-1,0), "TahomaBd"),
        ("ROWBACKGROUNDS",(0,1), (-1,-1), [WHITE, GRAY_LIGHT]),
        ("GRID",          (0,0), (-1,-1), 0.5, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 7),
        ("BOTTOMPADDING", (0,0), (-1,-1), 7),
        ("LEFTPADDING",   (0,0), (-1,-1), 10),
        ("RIGHTPADDING",  (0,0), (-1,-1), 10),
    ]))
    story.append(filter_type)
    story.append(sp(10))

    story.append(h2("การอ่านรายการ Log แต่ละอัน"))
    story.append(log_example_table([
        ("เส้นสีเขียวซ้าย",  "เข้าหอพัก (Entry)"),
        ("เส้นสีแดงซ้าย",    "ออกจากหอพัก (Exit)"),
        ("Face Scan  badge", "สแกนใบหน้าที่ประตู"),
        ("[ตรงเวลา]",         "เข้าก่อนเวลากำหนดของหอพัก"),
        ("[สาย]",             "เข้าหลังเวลากำหนดของหอพัก"),
    ]))
    story.append(sp(6))
    story.append(body(
        "รายการจัดเรียงตามวัน มีหัวข้อ 'วันนี้', 'เมื่อวาน' "
        "หรือวันที่ชัดเจนเพื่อให้อ่านง่าย"
    ))
    story.append(sp(16))

    # ── Section 6: Setting ────────────────────────────────────────────────
    story.append(section_header("6.  แท็บ Setting (ตั้งค่า)"))
    story.append(sp(10))
    story.append(body("แท็บนี้มีตัวเลือก 3 อย่าง:"))
    story.append(sp(8))

    setting_rows = [
        ("บัญชีของฉัน",  "ดูข้อมูลส่วนตัว: ชื่อ-นามสกุล เบอร์โทรศัพท์ และอีเมล"),
        ("ภาษา",         "เลือกภาษาไทยหรืออังกฤษ — แอปเปลี่ยนทุกหน้าทันทีโดยไม่ต้อง restart"),
        ("ออกจากระบบ",   "กดแล้วจะมีกล่อง confirm ก่อน กด 'ออกจากระบบ' เพื่อยืนยัน หรือ 'ยกเลิก' เพื่อกลับ"),
    ]
    story.append(info_table(setting_rows))
    story.append(sp(16))

    # ── Section 7: Account ────────────────────────────────────────────────
    story.append(section_header("7.  หน้าข้อมูลบัญชี (Account)"))
    story.append(sp(10))
    story.append(body(
        "เข้าถึงได้จาก Setting → บัญชีของฉัน "
        "หน้านี้แสดงข้อมูลผู้ปกครองที่ลงทะเบียนไว้:"
    ))
    story.append(sp(8))
    for item in ["ชื่อ-นามสกุล", "เบอร์โทรศัพท์", "อีเมล"]:
        story.append(bullet(item))
    story.append(sp(16))

    # ── Section 8: Push Notification ─────────────────────────────────────
    story.append(section_header("8.  การแจ้งเตือน (Push Notification)"))
    story.append(sp(10))
    story.append(body(
        "เมื่อบุตรหลาน <b>รูดบัตร หรือ สแกนใบหน้าที่ประตูหอพัก</b> "
        "แอปจะส่งการแจ้งเตือนมาทันที "
        "<b>แม้ไม่ได้เปิดแอปอยู่</b>"
    ))
    story.append(sp(8))

    notif_box = Table([[
        Paragraph(
            "ตัวอย่างการแจ้งเตือน:\n"
            "[ชื่อนักศึกษา] เข้าหอพัก\n"
            "ประตู: ประตูหลัก  •  เวลา 08:30 น.",
            ParagraphStyle("nb", fontName="Tahoma", fontSize=11,
                           textColor=BLACK, leading=18),
        )
    ]], colWidths=[16*cm])
    notif_box.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,-1), GRAY_LIGHT),
        ("BOX",           (0,0), (-1,-1), 1, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 12),
        ("BOTTOMPADDING", (0,0), (-1,-1), 12),
        ("LEFTPADDING",   (0,0), (-1,-1), 16),
        ("RIGHTPADDING",  (0,0), (-1,-1), 16),
    ]))
    story.append(notif_box)
    story.append(sp(6))
    story.append(body(
        "ข้อมูลในการแจ้งเตือนประกอบด้วย: ชื่อนักศึกษา, "
        "ประเภท (เข้า/ออก), ชื่อประตู, และเวลาที่เกิดเหตุการณ์"
    ))
    story.append(sp(16))

    # ── Section 9: ปัญหาที่พบบ่อย ────────────────────────────────────────
    story.append(section_header("9.  ปัญหาที่พบบ่อยและวิธีแก้ไข"))
    story.append(sp(10))

    faq = Table([
        [Paragraph("<b>ปัญหา</b>", S["body"]),
         Paragraph("<b>วิธีแก้ไข</b>", S["body"])],
        [Paragraph("'ไม่พบนักศึกษาที่เชื่อมต่อ'", S["body"]),
         Paragraph("ติดต่อเจ้าหน้าที่หอพักเพื่อเชื่อมบัญชีกับข้อมูลนักศึกษา", S["body"])],
        [Paragraph("'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์'", S["body"]),
         Paragraph("ตรวจสอบ WiFi หรือสัญญาณมือถือ แล้วลองใหม่อีกครั้ง", S["body"])],
        [Paragraph("อีเมล/รหัสผ่านไม่ถูกต้อง", S["body"]),
         Paragraph("ตรวจสอบตัวพิมพ์ใหญ่-เล็ก หากลืมรหัสผ่านให้ติดต่อเจ้าหน้าที่", S["body"])],
        [Paragraph("ข้อมูลไม่อัปเดต", S["body"]),
         Paragraph("กด Retry หรือรอสักครู่ — ระบบ refresh อัตโนมัติทุก 30 วินาที", S["body"])],
        [Paragraph("ไม่ได้รับการแจ้งเตือน", S["body"]),
         Paragraph("ตรวจสอบการอนุญาต Notification ของแอปในการตั้งค่าโทรศัพท์", S["body"])],
    ], colWidths=[6*cm, 10*cm])
    faq.setStyle(TableStyle([
        ("BACKGROUND",    (0,0), (-1,0), MFU_DARK),
        ("TEXTCOLOR",     (0,0), (-1,0), WHITE),
        ("FONTNAME",      (0,0), (-1,0), "TahomaBd"),
        ("ROWBACKGROUNDS",(0,1), (-1,-1), [WHITE, GRAY_LIGHT]),
        ("GRID",          (0,0), (-1,-1), 0.5, GRAY_MID),
        ("TOPPADDING",    (0,0), (-1,-1), 8),
        ("BOTTOMPADDING", (0,0), (-1,-1), 8),
        ("LEFTPADDING",   (0,0), (-1,-1), 10),
        ("RIGHTPADDING",  (0,0), (-1,-1), 10),
        ("VALIGN",        (0,0), (-1,-1), "TOP"),
    ]))
    story.append(faq)
    story.append(sp(16))

    # ── Section 10: ความปลอดภัย ───────────────────────────────────────────
    story.append(section_header("10.  ความปลอดภัยของระบบ"))
    story.append(sp(10))
    security_items = [
        "ระบบใช้ <b>JWT Token</b> สำหรับการยืนยันตัวตน — ทุก Request มีการตรวจสอบสิทธิ์",
        "ข้อมูลส่งผ่าน <b>HTTPS</b> ทุกครั้ง ป้องกันการดักจับข้อมูล",
        "แอปนี้สำหรับ <b>ผู้ปกครองเท่านั้น</b> — ไม่แชร์ข้อมูลกับบุคคลภายนอก",
        "Token หมดอายุอัตโนมัติใน <b>7 วัน</b> — จำเป็นต้อง Login ใหม่",
    ]
    for item in security_items:
        story.append(bullet(item))

    return story


# ── Main ──────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    out_path = os.path.join(
        os.path.dirname(__file__), "MFU_Dormitory_UserManual.pdf"
    )

    doc = MfuDocTemplate(
        out_path,
        pagesize=A4,
        topMargin=1.8*cm,
        bottomMargin=2.2*cm,
        leftMargin=1.8*cm,
        rightMargin=1.8*cm,
        title="MFU Dormitory — คู่มือการใช้งาน",
        author="Mae Fah Luang University",
        subject="คู่มือการใช้งานสำหรับผู้ปกครอง",
    )

    doc.build(build_story())
    print(f"PDF saved: {out_path}")
