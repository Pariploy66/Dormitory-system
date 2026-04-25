import { PrismaService } from '../common/prisma.service';
export declare class UpsertStudentDto {
    externalStudentId: string;
    studentCode: string;
    name: string;
}
export declare class LinkStudentDto {
    parentPhone: string;
    studentCode: string;
}
export declare class StudentsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    upsertStudent(dto: UpsertStudentDto): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        externalStudentId: string;
        studentCode: string;
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
        name: string;
        id: string;
        createdAt: Date;
        externalStudentId: string;
        studentCode: string;
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
