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
        const thaiStr = payload.accessTime
            .replace(/\.\d+/, '')
            .replace(/[Zz]$|[+-]\d{2}:\d{2}$/, '');
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
        const nowUtc = new Date();
        const since = new Date(Date.UTC(nowUtc.getUTCFullYear(), nowUtc.getUTCMonth(), nowUtc.getUTCDate()));
        since.setUTCDate(since.getUTCDate() - (days - 1));
        since.setTime(since.getTime() - 7 * 60 * 60 * 1000);
        const logs = await this.prisma.accessLog.findMany({
            where: { studentId, accessTime: { gte: since } },
            orderBy: { accessTime: 'desc' },
            take: 500,
            select: { id: true, accessTime: true, type: true, gateName: true },
        });
        return logs.map((log) => ({
            ...log,
            status: this.computeStatus(log.accessTime, log.type),
        }));
    }
    computeStatus(accessTime, type) {
        if (type !== 'IN')
            return 'ontime';
        const utcMin = accessTime.getUTCHours() * 60 + accessTime.getUTCMinutes();
        const thaiMin = (utcMin + 7 * 60) % (24 * 60);
        const CURFEW_START = 22 * 60 + 30;
        const CURFEW_END = 6 * 60;
        return thaiMin >= CURFEW_START || thaiMin < CURFEW_END ? 'late' : 'ontime';
    }
    async getMyProfile(parentId) {
        const parent = await this.prisma.parent.findUnique({
            where: { id: parentId },
            select: { id: true, name: true, phone: true, email: true, createdAt: true },
        });
        if (!parent)
            throw new common_1.NotFoundException('Parent not found');
        return parent;
    }
    async getMyStudents(parentId) {
        const mappings = await this.prisma.parentStudentMapping.findMany({
            where: { parentId },
            include: {
                student: {
                    select: { id: true, name: true, studentCode: true, dormitory: true, roomNumber: true },
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