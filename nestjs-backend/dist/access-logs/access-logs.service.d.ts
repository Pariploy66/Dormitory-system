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
        status: "late" | "ontime";
        id: string;
        type: import(".prisma/client").$Enums.AccessType;
        gateName: string;
        accessTime: Date;
    }[]>;
    private computeStatus;
    getMyProfile(parentId: string): Promise<{
        id: string;
        name: string;
        phone: string;
        email: string;
        createdAt: Date;
    }>;
    getMyStudents(parentId: string): Promise<{
        id: string;
        name: string;
        studentCode: string;
        dormitory: string;
        roomNumber: string;
    }[]>;
}
