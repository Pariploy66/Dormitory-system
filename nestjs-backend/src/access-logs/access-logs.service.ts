import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

export interface IngestPayload {
  externalStudentId: string;
  /**
   * Thai local time (ICT, UTC+7) written as an ISO-8601 string.
   * Any timezone designator is stripped and +07:00 is re-attached,
   * so ALL of the following are treated identically:
   *
   *   "2026-05-06T17:35:00"          → Thai 17:35 ✓
   *   "2026-05-06T17:35:00+07:00"    → Thai 17:35 ✓
   *   "2026-05-06T17:35:00.000Z"     → Thai 17:35 ✓  (Z is ignored)
   *
   * Just write the Thai clock reading — no UTC math needed.
   */
  accessTime: string;
  type: 'IN' | 'OUT';
  gateName: string;
}

@Injectable()
export class AccessLogsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  /**
   * Called by FastAPI via the internal endpoint.
   * Uses upsert to enforce deduplication (composite unique: student + time + type).
   */
  async ingest(payload: IngestPayload) {
    const student = await this.prisma.student.findUnique({
      where: { externalStudentId: payload.externalStudentId },
    });
    if (!student) return { skipped: true, reason: 'student not found' };

    // ── Timezone normalisation ───────────────────────────────────────────────
    // This system is entirely Thailand-based: the on-site hardware, FastAPI
    // integration, and manual Postman tests all report times in Thai local
    // time (ICT, UTC+7).  We therefore ALWAYS interpret the incoming datetime
    // as Thai time, regardless of whatever timezone designator the caller
    // appended (Z, +00:00, +07:00, or nothing).
    //
    // Algorithm:
    //   1. Strip fractional seconds  → "2026-05-06T17:35:00.000Z" → "...17:35:00Z"
    //   2. Strip timezone designator → "2026-05-06T17:35:00"
    //   3. Attach +07:00             → "2026-05-06T17:35:00+07:00"
    //
    // Result: new Date("2026-05-06T17:35:00+07:00") = UTC 10:35
    //         Flutter .toLocal() = Thai 17:35  ✓
    //
    // This means callers can write the Thai clock reading in ANY of these
    // formats and get the same correct result:
    //   "2026-05-06T17:35:00"          (no timezone)
    //   "2026-05-06T17:35:00+07:00"    (explicit Thai offset)
    //   "2026-05-06T17:35:00.000Z"     (bare Z — treated as Thai, not UTC)
    const thaiStr  = payload.accessTime
      .replace(/\.\d+/, '')                     // strip fractional seconds
      .replace(/[Zz]$|[+-]\d{2}:\d{2}$/, '');  // strip any timezone designator
    const accessTime = new Date(thaiStr + '+07:00');

    const log = await this.prisma.accessLog.upsert({
      where: {
        unique_access_event: {
          studentId: student.id,
          accessTime,
          type: payload.type,
        },
      },
      create: {
        studentId: student.id,
        accessTime,
        type: payload.type,
        gateName: payload.gateName,
      },
      update: {},  // no-op on duplicate → deduplication
    });

    // Fire push notification to all parents linked to this student
    await this.notifications.notifyParentsOfStudent(student, log);

    return { ok: true, logId: log.id };
  }

  /**
   * Fetch access logs for a student within the last `days` days (default 7),
   * enforcing that the requesting parent has a mapping to that student.
   *
   * Each record includes a computed `status` field:
   *   - "late"   → IN entry between 22:30 and 05:59 Thai time (crosses midnight)
   *   - "ontime" → all other IN entries and all OUT entries
   */
  async getLogsForStudent(parentId: string, studentId: string, days = 7) {
    // Security: verify parent owns this student
    const mapping = await this.prisma.parentStudentMapping.findFirst({
      where: { parentId, studentId },
    });
    if (!mapping) {
      throw new ForbiddenException(
        'You do not have access to this student\'s records',
      );
    }

    // "days=7" means the 7 Thai calendar days that include today.
    // We use UTC arithmetic + a 7-hour offset so the window starts at Thai
    // midnight (UTC-7h) of the first day, regardless of the server's TZ.
    // Example: days=7 on Thai May 6 → since = Thai Apr 30 00:00 = UTC Apr 29 17:00
    const nowUtc = new Date();
    const since = new Date(
      Date.UTC(
        nowUtc.getUTCFullYear(),
        nowUtc.getUTCMonth(),
        nowUtc.getUTCDate(),
      ),
    );
    since.setUTCDate(since.getUTCDate() - (days - 1)); // go back (days-1) UTC days
    since.setTime(since.getTime() - 7 * 60 * 60 * 1000); // shift to Thai midnight (UTC-7h)

    const logs = await this.prisma.accessLog.findMany({
      where: { studentId, accessTime: { gte: since } },
      orderBy: { accessTime: 'desc' },
      take: 500, // safety cap — 7 days rarely exceeds this
      select: {
        id: true,
        accessTime: true,
        type: true,
        gateName: true,
      },
    });

    // Attach computed status to each record
    return logs.map((log) => ({
      ...log,
      status: this.computeStatus(log.accessTime, log.type),
    }));
  }

  /**
   * Compute whether an IN entry is "late" or "ontime" based on Thai local time.
   *
   * Curfew window: 22:30 → 05:59 (crosses midnight).
   *   Late  = minutes-since-Thai-midnight ∈ [1350, 1440) ∪ [0, 360)
   *   OnTime = everything else (and all OUT entries)
   *
   * accessTime is stored as UTC in the database.
   * Thai time = UTC + 7 h, so we add 7 × 60 minutes before computing
   * minutes-since-midnight, then wrap modulo 1440 (24 × 60).
   */
  private computeStatus(
    accessTime: Date,
    type: 'IN' | 'OUT',
  ): 'late' | 'ontime' {
    if (type !== 'IN') return 'ontime';

    // Convert UTC stored time → Thai local minutes-since-midnight
    const utcMinutes = accessTime.getUTCHours() * 60 + accessTime.getUTCMinutes();
    const thaiMinutes = (utcMinutes + 7 * 60) % (24 * 60); // wrap at midnight

    const CURFEW_START = 22 * 60 + 30; // 22:30 = 1350 min
    const CURFEW_END   =  6 * 60;      // 06:00 = 360 min

    // The window [22:30, 06:00) wraps midnight, so we use OR not AND
    return thaiMinutes >= CURFEW_START || thaiMinutes < CURFEW_END
      ? 'late'
      : 'ontime';
  }

  /**
   * Return the profile of the authenticated parent (name, phone, email).
   * Used by the Flutter Account page under Settings.
   */
  async getMyProfile(parentId: string) {
    const parent = await this.prisma.parent.findUnique({
      where: { id: parentId },
      select: { id: true, name: true, phone: true, email: true, createdAt: true },
    });
    if (!parent) throw new NotFoundException('Parent not found');
    return parent;
  }

  /** Return all students linked to a parent (for the home screen) */
  async getMyStudents(parentId: string) {
    const mappings = await this.prisma.parentStudentMapping.findMany({
      where: { parentId },
      include: {
        student: {
          select: { id: true, name: true, studentCode: true },
        },
      },
    });
    return mappings.map((m) => m.student);
  }
}
