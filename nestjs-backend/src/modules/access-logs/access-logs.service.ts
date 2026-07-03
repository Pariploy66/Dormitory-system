import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { EventsGateway } from '../events/events.gateway';

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
   */
  accessTime: string;
  type: 'IN' | 'OUT';
  gateName: string;
  /** รูปภาพ — reference/profile photo from Access Control (optional). */
  photoUrl?: string;
  /** รูปภาพสแกน — live face-scan snapshot from Access Control (optional). */
  scanPhotoUrl?: string;
}

@Injectable()
export class AccessLogsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
    private readonly events: EventsGateway,
  ) {}

  // ── NewSystem handler: onCreate (POST /internal/access-logs) ───────────────
  /**
   * Called by FastAPI via the internal endpoint.
   * Uses upsert to enforce deduplication (composite unique: student + time + type).
   */
  async onCreate(payload: IngestPayload) {
    const student = await this.prisma.student.findUnique({
      where: { externalStudentId: payload.externalStudentId },
    });
    if (!student) return { skipped: true, reason: 'student not found' };

    // ── Timezone normalisation ─────────────────────────────────────────────
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
    const thaiStr = payload.accessTime
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
        photoUrl: payload.photoUrl ?? null,
        scanPhotoUrl: payload.scanPhotoUrl ?? null,
      },
      update: {
        // Backfill photos if a later duplicate carries them (idempotent).
        photoUrl: payload.photoUrl ?? undefined,
        scanPhotoUrl: payload.scanPhotoUrl ?? undefined,
      },
    });

    await this.notifications.notifyParentsOfStudent(student, log);
    this.events.emitLogCreated(student.id);

    return { ok: true, logId: log.id };
  }

  // ── NewSystem handler: onQuery (GET /me/profile) ───────────────────────────
  /** Return the profile of the authenticated parent (name, citizenId). */
  async onQuery(parentId: string) {
    const parent = await this.prisma.parent.findUnique({
      where: { id: parentId },
      select: { id: true, name: true, citizenId: true, createdAt: true },
    });
    if (!parent) throw new NotFoundException('Parent not found');
    return parent;
  }

  // ── NewSystem handler: onQuerys (GET /me/students) ─────────────────────────
  /**
   * Return the parent's ACTIVE (in-dorm) students via the registry, keyed by
   * the parent's citizen ID. Graduated/moved-out students are filtered out.
   * Each result includes the guardian relationship (FATHER/MOTHER/GUARDIAN).
   */
  async onQuerys(parentId: string) {
    const parent = await this.prisma.parent.findUnique({
      where: { id: parentId },
      select: { citizenId: true },
    });
    if (!parent) return [];

    const entries = await this.prisma.parentStudentRegistry.findMany({
      where: {
        parentCitizenId: parent.citizenId,
        student: { status: 'ACTIVE' },
      },
      include: {
        student: {
          select: {
            id: true,
            name: true,
            studentCode: true,
            dormitory: true,
            roomNumber: true,
          },
        },
      },
    });
    return entries.map((e) => ({ ...e.student, relationship: e.relationship }));
  }

  // ── NewSystem handler: onQueryLogs (GET /me/students/:id/logs) ─────────────
  /**
   * Fetch access logs for a student within the last `days` days (default 7),
   * enforcing that the requesting parent has a mapping to that student.
   *
   * Each record includes a computed `status` field:
   *   - "late"   → IN entry between 22:30 and 05:59 Thai time (crosses midnight)
   *   - "ontime" → all other IN entries and all OUT entries
   */
  async onQueryLogs(parentId: string, studentId: string, days = 7) {
    // Security: verify (via registry) that this parent is a guardian of this
    // student AND the student is still ACTIVE (in dorm).
    const parent = await this.prisma.parent.findUnique({
      where: { id: parentId },
      select: { citizenId: true },
    });
    const entry = parent
      ? await this.prisma.parentStudentRegistry.findFirst({
          where: {
            parentCitizenId: parent.citizenId,
            studentId,
            student: { status: 'ACTIVE' },
          },
        })
      : null;
    if (!entry) {
      throw new ForbiddenException(
        'You do not have access to this student\'s records',
      );
    }

    // "days=7" means the 7 Thai calendar days that include today.
    const nowUtc = new Date();
    const since = new Date(
      Date.UTC(
        nowUtc.getUTCFullYear(),
        nowUtc.getUTCMonth(),
        nowUtc.getUTCDate(),
      ),
    );
    since.setUTCDate(since.getUTCDate() - (days - 1));
    since.setTime(since.getTime() - 7 * 60 * 60 * 1000); // shift to Thai midnight

    const logs = await this.prisma.accessLog.findMany({
      where: { studentId, accessTime: { gte: since } },
      orderBy: { accessTime: 'desc' },
      take: 500,
      select: {
        id: true,
        accessTime: true,
        type: true,
        gateName: true,
        photoUrl: true,
        scanPhotoUrl: true,
      },
    });

    return logs.map((log) => ({
      id: log.id,
      accessTime: log.accessTime,
      type: log.type,
      gateName: log.gateName,
      imageUrl: log.photoUrl,
      scanImageUrl: log.scanPhotoUrl,
      status: this.computeStatus(log.accessTime, log.type),
    }));
  }

  // ── Private ────────────────────────────────────────────────────────────────
  /**
   * Determine whether an IN entry falls inside the curfew window.
   *
   * Curfew: 22:30 → 05:59 Thai time (ICT, UTC+7) — crosses midnight.
   *   Thai minutes-since-midnight = (UTC_hh × 60 + UTC_mm + 420) mod 1440
   *
   *   Late  when: thaiMin >= 1350  (22:30–23:59)
   *            OR thaiMin <   360  (00:00–05:59)
   */
  private computeStatus(
    accessTime: Date,
    type: 'IN' | 'OUT',
  ): 'late' | 'ontime' {
    if (type !== 'IN') return 'ontime';

    const utcMin  = accessTime.getUTCHours() * 60 + accessTime.getUTCMinutes();
    const thaiMin = (utcMin + 7 * 60) % (24 * 60);

    const CURFEW_START = 22 * 60 + 30; // 1350 min
    const CURFEW_END   =  6 * 60;      //  360 min

    return thaiMin >= CURFEW_START || thaiMin < CURFEW_END ? 'late' : 'ontime';
  }
}
