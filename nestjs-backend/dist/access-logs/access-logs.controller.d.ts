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
    myStudents(req: any): Promise<{
        name: string;
        id: string;
        studentCode: string;
    }[]>;
    logs(req: any, studentId: string, limit?: string): Promise<{
        id: string;
        type: import(".prisma/client").$Enums.AccessType;
        gateName: string;
        accessTime: Date;
    }[]>;
}
export {};
