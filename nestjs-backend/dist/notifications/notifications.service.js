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
var NotificationsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationsService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const admin = require("firebase-admin");
const prisma_service_1 = require("../common/prisma.service");
let NotificationsService = NotificationsService_1 = class NotificationsService {
    constructor(prisma, config) {
        this.prisma = prisma;
        this.config = config;
        this.logger = new common_1.Logger(NotificationsService_1.name);
    }
    onModuleInit() {
        const serviceAccountPath = this.config.get('FIREBASE_SERVICE_ACCOUNT_PATH');
        if (!serviceAccountPath) {
            this.logger.warn('FIREBASE_SERVICE_ACCOUNT_PATH not set — FCM disabled');
            return;
        }
        const serviceAccount = require(serviceAccountPath);
        this.firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });
        this.logger.log('Firebase Admin SDK initialised');
    }
    async notifyParentsOfStudent(student, log) {
        if (!this.firebaseApp)
            return;
        const mappings = await this.prisma.parentStudentMapping.findMany({
            where: { studentId: student.id },
            include: {
                parent: {
                    include: { devices: { select: { fcmToken: true } } },
                },
            },
        });
        const tokens = mappings.flatMap((m) => m.parent.devices.map((d) => d.fcmToken));
        if (!tokens.length)
            return;
        const direction = log.type === 'IN' ? 'เข้า' : 'ออก';
        const timeStr = log.accessTime.toLocaleTimeString('th-TH', {
            hour: '2-digit',
            minute: '2-digit',
        });
        const message = {
            tokens,
            notification: {
                title: `${student.name} ${direction}หอพัก`,
                body: `ประตู: ${log.gateName} · เวลา ${timeStr}`,
            },
            data: {
                studentId: student.id,
                type: log.type,
                gateName: log.gateName,
                accessTime: log.accessTime.toISOString(),
            },
            android: { priority: 'high' },
            apns: { payload: { aps: { sound: 'default' } } },
        };
        try {
            const response = await admin.messaging().sendEachForMulticast(message);
            this.logger.log(`FCM sent: ${response.successCount} ok, ${response.failureCount} failed`);
            response.responses.forEach(async (r, i) => {
                if (!r.success &&
                    (r.error?.code === 'messaging/invalid-registration-token' ||
                        r.error?.code === 'messaging/registration-token-not-registered')) {
                    await this.prisma.device
                        .delete({ where: { fcmToken: tokens[i] } })
                        .catch(() => null);
                }
            });
        }
        catch (err) {
            this.logger.error('FCM send error', err);
        }
    }
};
exports.NotificationsService = NotificationsService;
exports.NotificationsService = NotificationsService = NotificationsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        config_1.ConfigService])
], NotificationsService);
//# sourceMappingURL=notifications.service.js.map