import {
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

// ── Shape of the ThaID /oauth2/token response (BORA API spec §6.2.2) ─────────
export interface ThaidTokenResponse {
  access_token: string;
  token_type: string;
  expire_in: number; // ⚠️ Unix timestamp (seconds), NOT a duration
  scope: string;
  refresh_token?: string;
  id_token?: string; // present only when scope includes "openid"
  pid?: string; // top-level only when scope has NO openid
  name?: string;
}

// ── Client for the ThaID (BORA/DOPA) OAuth2 API ──────────────────────────────
// Single responsibility: talk to ThaID only. Mirrors the FastAPI external_client
// pattern — one client file per external API. client_secret stays server-side.
@Injectable()
export class ThaidClient {
  private readonly logger = new Logger(ThaidClient.name);

  constructor(private readonly config: ConfigService) {}

  private cfg(key: string): string {
    const value = this.config.get<string>(key);
    if (!value) throw new Error(`Missing required env: ${key}`);
    return value;
  }

  /** Build the authorization URL the user opens to sign in (BORA API §6.1.1). */
  buildAuthUrl(state: string): string {
    const clientId = this.cfg('THAID_CLIENT_ID');
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: clientId,
      redirect_uri: this.cfg('THAID_REDIRECT_URI'),
      scope: this.cfg('THAID_SCOPE'),
      state,
    });
    return `${this.cfg('THAID_BASE_URL')}/api/v2/oauth2/auth/?${params.toString()}`;
  }

  /**
   * Exchange a one-time authorization code for tokens (BORA API §6.2.1).
   * The code is valid 30 seconds and single-use, so call this immediately.
   * Authorization: Basic Base64(client_id:client_secret).
   */
  async exchangeToken(code: string): Promise<ThaidTokenResponse> {
    const clientId = this.cfg('THAID_CLIENT_ID');
    const clientSecret = this.cfg('THAID_CLIENT_SECRET');
    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');

    const body = new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: this.cfg('THAID_REDIRECT_URI'),
    });

    const res = await fetch(`${this.cfg('THAID_BASE_URL')}/api/v2/oauth2/token/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        Authorization: `Basic ${basic}`,
      },
      body: body.toString(),
    });

    if (!res.ok) {
      const text = await res.text().catch(() => '');
      this.logger.warn(`ThaID token exchange failed (${res.status}): ${text}`);
      throw new UnauthorizedException(this.mapError(res.status, text));
    }

    return (await res.json()) as ThaidTokenResponse;
  }

  // ── Private ────────────────────────────────────────────────────────────────
  /** Translate ThaID error responses (BORA API error table) to Thai messages. */
  private mapError(status: number, body: string): string {
    if (body.includes('user_denied')) return 'ผู้ใช้ยกเลิกการเข้าสู่ระบบ';
    if (body.includes('Invalid Authorization Code'))
      return 'รหัสยืนยันหมดอายุ กรุณาเข้าสู่ระบบใหม่';
    if (body.includes('duplicate_request')) return 'คำขอซ้ำ กรุณาลองใหม่';
    if (status === 401) return 'ไม่ได้รับอนุญาตให้เข้าถึง ThaID';
    return 'การยืนยันตัวตนกับ ThaID ล้มเหลว';
  }
}
