import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'crypto';
import { PrismaService } from '../../common/prisma.service';
import { ThaidClient } from './thaid.client';

// Claims we read out of the ThaID id_token (scope=openid).
interface ThaidIdClaims {
  sub: string; // stable subject identifier → parent.thaidSub
  pid?: string; // national ID (13 digits) → parent.citizenId
  name?: string; // Thai full name
  [key: string]: unknown;
}

// Request metadata captured for the app sign-in/out audit trail (auth_logs).
export interface AuthLogMeta {
  ipAddress?: string;
  userAgent?: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly thaid: ThaidClient,
  ) {}

  // ── ThaID handler: getLoginUrl (GET /auth/thaid/login-url) ──────────────────
  /** Return the ThaID authorization URL for the client to open. */
  getLoginUrl() {
    const state = randomUUID();
    return { url: this.thaid.buildAuthUrl(state), state };
  }

  // ── ThaID handler: onThaidLogin (POST /auth/thaid) ──────────────────────────
  /**
   * Exchange the authorization code → read identity → upsert parent → issue JWT.
   * Parent is keyed by citizenId (pid); thaidSub + name are filled/refreshed here.
   * Records a LOGIN entry in auth_logs (app sign-in audit trail).
   */
  async onThaidLogin(code: string, meta?: AuthLogMeta) {
    const tokens = await this.thaid.exchangeToken(code);

    // With scope=openid, pid/name live inside id_token; otherwise top-level.
    const claims = this.decodeIdToken(tokens.id_token);
    const citizenId = claims?.pid ?? tokens.pid;
    const sub = claims?.sub;
    const name = claims?.name ?? tokens.name ?? '';

    if (!citizenId || !sub) {
      throw new UnauthorizedException('ThaID ไม่ส่งข้อมูลที่จำเป็น (pid/sub)');
    }

    const parent = await this.prisma.parent.upsert({
      where: { citizenId },
      create: { citizenId, thaidSub: sub, name, isVerified: true },
      update: { thaidSub: sub, name: name || undefined, isVerified: true },
    });

    await this.writeAuthLog(parent.id, 'LOGIN', meta);
    return this.signToken(parent.id);
  }

  // ── Handler: onLogout (POST /auth/logout) ───────────────────────────────────
  /**
   * Record a LOGOUT entry. JWT is stateless — the client discards its token;
   * this endpoint exists purely to log the app sign-out event.
   */
  async onLogout(parentId: string, meta?: AuthLogMeta) {
    await this.writeAuthLog(parentId, 'LOGOUT', meta);
    return { ok: true };
  }

  // ── Handler: onUpdate (POST /auth/device — upsert FCM token) ────────────────
  /** Register or update FCM token for push notifications. */
  async onUpdate(parentId: string, fcmToken: string) {
    return this.prisma.device.upsert({
      where: { fcmToken },
      create: { parentId, fcmToken },
      update: { parentId },
    });
  }

  // ── Private ──────────────────────────────────────────────────────────────────
  /**
   * Decode the id_token payload.
   * NOTE (POC): signature is NOT verified — ThaID's public key (JWKS) is not
   * provided in the sandbox docs. Production MUST verify the signature.
   */
  private decodeIdToken(idToken?: string): ThaidIdClaims | null {
    if (!idToken) return null;
    const decoded = this.jwt.decode(idToken);
    return (decoded as ThaidIdClaims) ?? null;
  }

  private signToken(parentId: string) {
    return {
      accessToken: this.jwt.sign({ sub: parentId }),
      parentId,
    };
  }

  /** Append an app sign-in/out event to auth_logs (never blocks the request). */
  private async writeAuthLog(
    parentId: string,
    event: 'LOGIN' | 'LOGOUT',
    meta?: AuthLogMeta,
  ) {
    await this.prisma.authLog.create({
      data: {
        parentId,
        event,
        ipAddress: meta?.ipAddress,
        userAgent: meta?.userAgent,
      },
    });
  }
}
