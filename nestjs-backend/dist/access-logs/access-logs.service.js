"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AccessLogsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma.service");
const notifications_service_1 = require("../notifications/notifications.service");
let AccessLogsService = class AccessLogsService {
    constructor(prisma, notifications) {
        this.prisma = prisma;
        this.notifications = notifications;
    }
    async ingest(payload) {
        const student = await this.prisma.student.findUnique({
            where: { externalStudentId: payload.externalStudentId },
        });
        if (!student)
            return { skipped: true, reason: 'student not found' };
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
            update: {},
        });
        await this.notifications.notifyParentsOfStudent(student, log);
        return { ok: true, logId: log.id };
    }
    async getLogsForStudent(parentId, studentId, days = 7) {
        const mapping = await this.prisma.parentStudentMapping.findFirst({
            where: { parentId, studentId },
        });
        if (!mapping) {
            throw new common_1.ForbiddenException('You do not have access to this student\'s records');
        }
        const since = new Date();
        since.setDate(since.getDate() - (days - 1));
        since.setHours(0, 0, 0, 0);
        return this.prisma.accessLog.findMany({
            where: { studentId, accessTime: { gte: since } },
            orderBy: { accessTime: 'desc' },
            take: 500,
            select: {
                id: true,
                accessTime: true,
                type: true,
                gateName: true,
            },
        });
    }
    async getMyStudents(parentId) {
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
};
exports.AccessLogsService = AccessLogsService;
exports.AccessLogsService = AccessLogsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        notifications_service_1.NotificationsService])
], AccessLogsService);
//# sourceMappingURL=access-logs.service.js.map