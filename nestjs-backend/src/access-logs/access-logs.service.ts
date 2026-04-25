import {
  Injectable,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../common/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

export interface IngestPayload {
  externalStudentId: string;
  accessTime: string;   // ISO-8601
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

    const accessTime = new Date(payload.accessTime);

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
   * Fetch access logs for a student, enforcing that the requesting parent
   * actually has a mapping to that student.
   */
  async getLogsForStudent(parentId: string, studentId: string, limit = 50) {
    // Security: verify parent owns this student
    const mapping = await this.prisma.parentStudentMapping.findFirst({
      where: { parentId, studentId },
    });
    if (!mapping) {
      throw new ForbiddenException(
        'You do not have access to this student\'s records',
      );
    }

    return this.prisma.accessLog.findMany({
      where: { studentId },
      orderBy: { accessTime: 'desc' },
      take: limit,
      select: {
        id: true,
        accessTime: true,
        type: true,
        gateName: true,
      },
    });
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
