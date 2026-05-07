import { AccessLogsService, IngestPayload } from './access-logs.service';
declare class IngestDto implements IngestPayload {
    externalStudentId: string;
    accessTime: string;
    type: 'IN' | 'OUT';
    gateName: string;
}
export declare class AccessLogsController {
    private readonly service;
    constructor(service: AccessLogsService);
    ingest(dto: IngestDto): Promise<{
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
    myProfile(req: any): Promise<{
        id: string;
        createdAt: Date;
        name: string;
        phone: string;
        email: string;
    }>;
    myStudents(req: any): Promise<{
        id: string;
        studentCode: string;
        name: string;
    }[]>;
    logs(req: any, studentId: string, days?: string): Promise<{
        status: "late" | "ontime";
        id: string;
        accessTime: Date;
        type: import(".prisma/client").$Enums.AccessType;
        gateName: string;
    }[]>;
}
export {};
