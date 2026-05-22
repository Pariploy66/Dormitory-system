import { PrismaService } from '../common/prisma.service';
export declare class UpsertStudentDto {
    externalStudentId: string;
    studentCode: string;
    name: string;
    dormitory?: string;
    roomNumber?: string;
    room_number?: string;
}
export declare class LinkStudentDto {
    parentPhone: string;
    studentCode: string;
}
export declare class StudentsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    upsertStudent(dto: UpsertStudentDto): Promise<{
        id: string;
        name: string;
        createdAt: Date;
        externalStudentId: string;
        studentCode: string;
        dormitory: string | null;
        roomNumber: string | null;
    }>;
    linkStudentToParent(dto: LinkStudentDto): Promise<{
        ok: boolean;
        reason: string;
    } | {
        ok: boolean;
        reason?: undefined;
    }>;
}
export declare class StudentsController {
    private readonly service;
    constructor(service: StudentsService);
    upsert(dto: UpsertStudentDto): Promise<{
        id: string;
        name: string;
        createdAt: Date;
        externalStudentId: string;
        studentCode: string;
        dormitory: string | null;
        roomNumber: string | null;
    }>;
    link(dto: LinkStudentDto): Promise<{
        ok: boolean;
        reason: string;
    } | {
        ok: boolean;
        reason?: undefined;
    }>;
}
export declare class StudentsModule {
}
