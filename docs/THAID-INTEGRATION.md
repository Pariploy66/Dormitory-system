# คู่มือเชื่อม ThaID (ThaID Integration Guide)

วิธีเชื่อม ThaID (OAuth2 ของกรมการปกครอง) เป็นระบบ login ของโปรเจคนี้ —
ตั้งแต่ภาพรวม, โค้ดที่ทำจริง, flow, ปัญหาที่แก้, จนถึง prompt สำหรับนำไปใช้โปรเจคอื่น

---

## 1. ภาพรวม (แบบง่าย)

ใช้ **OAuth2 Authorization Code flow** — คล้าย "Login with Google" แต่เป็นระบบบัตรประชาชนของรัฐ

**ตัวละคร 3 ตัว**
- **แอป** = แอปในมือถือ
- **ThaID** = ระบบตรวจบัตรประชาชนของรัฐ
- **เซิร์ฟเวอร์เรา (backend)** = คนกลางที่เก็บความลับ + ตัดสินว่าใครเข้าได้

**ขั้นตอน (เล่าเป็นเรื่อง)**
1. กดปุ่ม "เข้าสู่ระบบด้วย ThaID"
2. แอปถามเซิร์ฟเวอร์เรา → "ขอที่อยู่หน้า login ThaID"
3. แอปเปิดหน้า ThaID (ในแอป)
4. ใส่เลขบัตรประชาชน 13 หลัก + ยืนยัน
5. ThaID ตรวจว่าเป็นเราจริง → ส่ง "ตั๋ว" (code) กลับมา
6. แอปคว้าตั๋ว → ส่งให้เซิร์ฟเวอร์เรา
7. เซิร์ฟเวอร์เอาตั๋วไปแลกกับ ThaID → ได้ข้อมูลตัวจริง (เลขบัตร + ชื่อ)
   *(ขั้นนี้ backend ทำ เพราะมี "กุญแจลับ" ที่แอปห้ามถือ)*
8. เซิร์ฟเวอร์เช็ค → "เป็นผู้ปกครองของนักศึกษาในหอไหม?" → ไม่ใช่ = ไม่ให้เข้า
9. ผ่าน → เซิร์ฟเวอร์ออก "บัตรผ่าน" (JWT) ให้แอป
10. แอปเก็บบัตรผ่าน → เข้าหน้าหลัก

---

## 2. Config (env)

```
THAID_BASE_URL="https://imauthsbx.bora.dopa.go.th"   # endpoint OAuth (sandbox)
THAID_CLIENT_ID="..."                                 # จากใบลงทะเบียน RP
THAID_CLIENT_SECRET="..."                             # ลับ — อยู่ backend เท่านั้น
THAID_REDIRECT_URI="https://mfuengage.mfu.ac.th"      # callback ที่ลงทะเบียนไว้ (ต้องตรงเป๊ะ)
THAID_SCOPE="pid name openid"                          # openid = ได้ id_token (มี sub/pid/name)
```

---

## 3. Backend (NestJS) — 5 สเต็ป

### 3.1 `modules/auth/thaid.client.ts` — คุยกับ ThaID โดยตรง

```ts
// สร้าง URL หน้า login
buildAuthUrl(state) {
  const params = new URLSearchParams({
    response_type: 'code', client_id, redirect_uri, scope, state,
  });
  return `${BASE}/api/v2/oauth2/auth/?${params}`;   // ⚠️ /auth/ มี slash ท้าย, client_id เป็น query
}

// แลก code เป็น token (ฝั่ง server เท่านั้น)
async exchangeToken(code) {
  const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  const res = await fetch(`${BASE}/api/v2/oauth2/token/`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: `Basic ${basic}`,
    },
    body: new URLSearchParams({ grant_type: 'authorization_code', code, redirect_uri }),
  });
  return res.json();   // { id_token, access_token, ... }
}
```

### 3.2 `modules/auth/auth.service.ts` — logic

```ts
getLoginUrl() {
  const state = randomUUID();
  return { url: thaid.buildAuthUrl(state), state };
}

async onThaidLogin(code) {
  const tokens = await thaid.exchangeToken(code);
  const claims = this.jwt.decode(tokens.id_token);   // { sub, pid, name }

  // เช็คสิทธิ์ (โปรเจคนี้: ต้องเป็นผู้ปกครองของนักศึกษาที่ active)
  const ok = await prisma.parentStudentRegistry.count({
    where: { parentCitizenId: claims.pid, student: { status: 'ACTIVE' } },
  });
  if (ok === 0) throw new ForbiddenException('ไม่มีสิทธิ์เข้าถึง');

  const parent = await prisma.parent.upsert({
    where: { citizenId: claims.pid },
    create: { citizenId: claims.pid, thaidSub: claims.sub, name: claims.name },
    update: { thaidSub: claims.sub, name: claims.name },
  });
  return { accessToken: this.jwt.sign({ sub: parent.id }), parentId: parent.id };
}
```

### 3.3 `modules/auth/auth.controller.ts` — endpoints

```ts
@Get('thaid/login-url')  loginUrl() { return auth.getLoginUrl(); }
@Post('thaid')           login(@Body() dto) { return auth.onThaidLogin(dto.code); }
```

### 3.4 เพิ่ม `ThaidClient` ใน `auth.module.ts` → `providers`
### 3.5 `jwt.strategy.ts` — ตรวจ JWT ของระบบเราเอง (ออกเอง ตรวจเอง)

---

## 4. Frontend (Flutter) — 3 สเต็ป

### 4.1 `pubspec.yaml` → เพิ่ม `webview_flutter: ^4.7.0`

### 4.2 `features/auth/presentation/thaid_login_screen.dart` — webview คว้า code

```dart
WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(NavigationDelegate(
    onNavigationRequest: (req) {
      // พอ ThaID เด้งกลับมาที่ redirect_uri → คว้า code แล้วปิด (ยังไม่ทันโหลดหน้าจริง)
      if (req.url.startsWith(redirectUri) && req.url.contains('code=')) {
        final code = Uri.parse(req.url).queryParameters['code'];
        Navigator.pop(context, code);
        return NavigationDecision.prevent;
      }
      return NavigationDecision.navigate;
    },
  ))
  ..loadRequest(Uri.parse(authUrl));
```

### 4.3 `core/services/api_service.dart`

```dart
Future<String> getThaidLoginUrl() async {
  final res = await _api.get('/auth/thaid/login-url');
  return res.data['data']['url'];
}

Future<void> thaidLogin(String code) async {
  final res = await _api.post('/auth/thaid', data: {'code': code});
  await _storage.saveToken(res.data['data']['accessToken']);   // เก็บ JWT
}
```

**ปุ่ม login:** `getThaidLoginUrl()` → เปิด `ThaidLoginScreen` → ได้ code → `thaidLogin(code)` → เข้า dashboard

---

## 5. Endpoints

| Method | Path | ทำอะไร |
|---|---|---|
| `GET` | `/auth/thaid/login-url` | คืน URL ThaID → `{ url, state }` |
| `POST` | `/auth/thaid` | รับ `{code}` → คืน `{ accessToken, parentId }` |

---

## 6. Flow จริงตอน user กดปุ่ม (ทีละสเต็ป)

```
1. user กด "Login with ThaID"
2. แอป → GET /auth/thaid/login-url → backend สร้าง URL → คืนแอป
3. แอปเปิด URL ใน webview → หน้า ThaID
4. (sandbox) พิมพ์เลขบัตร 13 หลัก + ยืนยัน
5. ThaID เด้งกลับ → {redirect_uri}?code=xxx
6. webview ดักจับ → คว้า code → ปิด
7. แอป → POST /auth/thaid {code}
8. backend แลก token (Basic auth ลับ) → ได้ id_token
9. decode → sub, pid, name
10. เช็คสิทธิ์ → ผ่าน → upsert parent → ออก JWT
11. แอปเก็บ JWT → เข้า dashboard
```

---

## 7. ปัญหาที่เจอ + วิธีแก้ (สำคัญ — จดไว้)

| ปัญหา | สาเหตุ | แก้ |
|---|---|---|
| 404 ตอนขอ auth | path ผิด `/oauth2/{client_id}/auth` | ที่ถูก **`/oauth2/auth/`** (client_id เป็น query + มี `/` ท้าย) |
| `unauthorized_client` | `client_secret` พิมพ์ผิด (`I` ใหญ่ vs `l` เล็ก) | เทสต์ผ่าน endpoint **introspect** จนเจอตัวถูก |
| `ERR_NAME_NOT_RESOLVED` | `THAID_BASE_URL` พิมพ์ผิด | BASE = `imauthsbx.bora.dopa.go.th` (mfuengage เป็นแค่ callback) |
| เว็บ login ไม่ได้ | `webview_flutter` รองรับแค่มือถือ | รันบนมือถือ / emulator / LDPlayer |

**หลักสำคัญ**
- `client_secret` อยู่ **backend เท่านั้น** — แอปส่งแค่ `code`
- `code` อายุ **30 วินาที ใช้ครั้งเดียว** → แลก token ทันทีฝั่ง server
- `redirect_uri` ต้อง **ตรงกับที่ลงทะเบียน** เป๊ะ — มือถือใช้ webview ดักจับได้เลย (ไม่ต้องโหลดหน้าจริง)
- `scope` ต้องมี `openid` ถึงจะได้ `id_token`
- **Production:** ต้อง verify signature ของ `id_token` ด้วย JWKS จากกรมการปกครอง (POC ยังแค่ decode)

---

## 8. Prompt สำหรับนำไปใช้โปรเจคอื่น

คัดลอกไปวางเพื่อสั่งให้ AI ทำ ThaID integration ในโปรเจคใหม่:

```
ช่วย integrate ThaID (OAuth2 ของกรมการปกครอง) เป็นระบบ login ให้โปรเจคนี้

Tech stack: [ใส่ของคุณ เช่น NestJS backend + Flutter mobile]

Flow ที่ต้องการ (Authorization Code):
1. Frontend ขอ auth URL จาก backend
2. เปิด URL ใน webview (มือถือ) → user ใส่เลขบัตร → ThaID คืน code ที่ redirect_uri
3. Frontend คว้า code จาก redirect ส่งให้ backend
4. Backend แลก code เป็น token → decode id_token เอา sub/pid/name → upsert user → ออก JWT ของระบบเอง

ข้อกำหนด ThaID ที่ต้องทำให้ถูก (สำคัญมาก):
- Auth endpoint: GET {BASE}/api/v2/oauth2/auth/  (มี slash ท้าย, client_id เป็น query param ไม่ใช่ path)
- Token endpoint: POST {BASE}/api/v2/oauth2/token/
  Header Authorization: Basic base64(client_id:client_secret)
  Body: grant_type=authorization_code & code & redirect_uri
- scope ต้องมี "openid" ถึงจะได้ id_token (ข้างในมี sub=ตัวระบุตัวตน, pid=เลขบัตร13หลัก, name=ชื่อ)
- code อายุ 30 วิ ใช้ครั้งเดียว → แลก token ทันทีฝั่ง server
- redirect_uri ต้องตรงกับที่ลงทะเบียนไว้เป๊ะ
- client_secret เก็บฝั่ง backend เท่านั้น ห้ามอยู่ใน frontend
- id_token: POC decode ได้เลย / production ต้อง verify signature ด้วย JWKS

Config (env): THAID_BASE_URL, THAID_CLIENT_ID, THAID_CLIENT_SECRET,
THAID_REDIRECT_URI, THAID_SCOPE="pid name openid"

Backend ต้องมี: buildAuthUrl(state), exchangeToken(code),
endpoint GET /auth/thaid/login-url + POST /auth/thaid

Frontend (Flutter): ใช้ webview_flutter เปิด auth URL แล้ว intercept
navigation ที่ redirect_uri เพื่อคว้า code (onNavigationRequest → prevent + pop code)

ช่วยเขียนโค้ดครบ + บอกวิธีเทสต์ทีละขั้นด้วย ยังไม่ต้องแตะโค้ดจนกว่าจะอธิบาย architecture ให้เข้าใจก่อน
```

---

> เอกสารนี้อธิบายเฉพาะส่วน ThaID login เท่านั้น — ส่วน registry / student status / multi-child
> ดูใน `docs/changes/ARCH-DORM-004-registry-status-relationship.md`
