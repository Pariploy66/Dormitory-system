import { PrismaService } from '../common/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
export interface IngestPayload {
    externalStudentId: string;
    accessTime: string;
    type: 'IN' | 'OUT';
    gateName: string;
}
export declare class AccessLogsService {
    private readonly prisma;
    private readonly notifications;
    constructor(prisma: PrismaService, notifications: NotificationsService);
    ingest(payload: IngestPayload): Promise<{
        skipped: boolean;
        reason: string;
        ok?: undefined;
        logId?: undefined;
    } | {
        ok: boolean;
        logId: string;
        skipped?: undefined;
        reason?: undefined;
    }>;
    getLogsForStudent(parentId: string, studentId: string, days?: number): Promise<{
        id: string;
        accessTime: Date;
        type: import(".prisma/client").$Enums.AccessType;
        gateName: string;
    }[]>;
    getMyStudents(parentId: string): Promise<{
        id: string;
        studentCode: string;
        name: string;
    }[]>;
}
